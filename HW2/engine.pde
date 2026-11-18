public class Engine {
    ShapeRenderer shapeRenderer;
    Inspector inspector;
    Hierarchy hierarchy;

    Vector3[] boundary = { new Vector3(-1, -1, 0), new Vector3(-1, 1, 0), new Vector3(1, 1, 0), new Vector3(1, -1, 0) };

    // SSAA bonus: 每個螢幕像素維護 4 個 sub-pixel sample。
    final int SSAA_SAMPLE_COUNT = 4;
    float[] ssaaDepth;
    color[] ssaaColor;
    boolean[] ssaaCovered;

    ArrayList<ShapeButton> shapeButton = new ArrayList<ShapeButton>();
    ShapeButton rectangleButton;
    ShapeButton starButton;

    public Engine() {
        shapeRenderer = new ShapeRenderer();
        inspector = new Inspector();
        hierarchy = new Hierarchy(shapeRenderer.shapes);

        ssaaDepth = new float[width * height * SSAA_SAMPLE_COUNT];
        ssaaColor = new color[width * height * SSAA_SAMPLE_COUNT];
        ssaaCovered = new boolean[width * height * SSAA_SAMPLE_COUNT];

        initButton();

    }

    // 每一幀開始前重置所有 sample 的深度、顏色與覆蓋狀態。
    public void clearSSAA() {
        for (int i = 0; i < ssaaDepth.length; i++) {
            ssaaDepth[i] = Float.POSITIVE_INFINITY;
            ssaaColor[i] = color(250);
            ssaaCovered[i] = false;
        }
    }

    // 將每個像素的 4 個 sample resolve 成最終螢幕顏色。
    public void resolveSSAA() {
        loadPixels();

        for (int y = 50; y < height - 50; y++) {
            for (int x = 20; x < 520; x++) {
                int red = 0;
                int green = 0;
                int blue = 0;

                for (int s = 0; s < SSAA_SAMPLE_COUNT; s++) {
                    int sampleIndex = (y * width + x) * SSAA_SAMPLE_COUNT + s;
                    if (ssaaCovered[sampleIndex]) {
                        red += red(ssaaColor[sampleIndex]);
                        green += green(ssaaColor[sampleIndex]);
                        blue += blue(ssaaColor[sampleIndex]);
                    } else {
                        // 未被圖形覆蓋的 sample 使用目前的像素背景色。
                        red += red(pixels[y * width + x]);
                        green += green(pixels[y * width + x]);
                        blue += blue(pixels[y * width + x]);
                    }
                }

                pixels[y * width + x] =
                    color(red / SSAA_SAMPLE_COUNT,
                          green / SSAA_SAMPLE_COUNT,
                          blue / SSAA_SAMPLE_COUNT);
            }
        }

        updatePixels();
    }

    // 寫入一個 sub-pixel；深度較近時才更新該 sample 的顏色。
    public boolean writeSSAA(float x, float y, int sampleNumber,
                              float depth, color shapeColor) {
        int px = int(x);
        int py = int(y);

        if (px < 0 || px >= width || py < 0 || py >= height)
            return false;

        int sampleIndex =
            (py * width + px) * SSAA_SAMPLE_COUNT + sampleNumber;

        if (!ssaaCovered[sampleIndex] || depth < ssaaDepth[sampleIndex]) { //判斷哪個圖形在上面
            ssaaDepth[sampleIndex] = depth;
            ssaaColor[sampleIndex] = shapeColor;
            ssaaCovered[sampleIndex] = true;
            return true;
        }

        return false;
    }

    public void initButton() {
        rectangleButton = new ShapeButton(20, 10, 30, 30) {
            @Override
            public void show() {
                super.show();
                stroke(0);
                line(pos.x + 2, pos.y + 2, pos.x + size.x - 2, pos.y + 2);
                line(pos.x + 2, pos.y + size.y - 2, pos.x + size.x - 2, pos.y + size.y - 2);
                line(pos.x + size.x - 2, pos.y + 2, pos.x + size.x - 2, pos.y + size.y - 2);
                line(pos.x + 2, pos.y + 2, pos.x + 2, pos.y + size.y - 2);
            }

            @Override
            public Shape renderShape() {
                return new Rectangle();
            }
        };

        rectangleButton.setBoxAndClickColor(color(250), color(150));
        shapeButton.add(rectangleButton);

        starButton = new ShapeButton(60, 10, 30, 30) {
            @Override
            public void show() {
                super.show();
            }

            @Override
            public Shape renderShape() {
                return new Star();
            }
        };

        starButton.setImage(loadImage("star.png"));
        starButton.setBoxAndClickColor(color(250), color(150));
        shapeButton.add(starButton);
    }

    void run() {
        // 每幀先清除 SSAA buffer，再繪製圖形並於 ShapeRenderer resolve。
        clearSSAA();
        shapeRenderer.run();
        inspector.run();
        hierarchy.run();

        for (ShapeButton sb : shapeButton) {
            sb.run(() -> {
                shapeRenderer.addShape(sb.renderShape());
            });
        }

    }

}
