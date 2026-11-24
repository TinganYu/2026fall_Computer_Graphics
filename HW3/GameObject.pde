public class GameObject {
    Transform transform;
    Mesh mesh;
    String name;
    Shader shader;

    GameObject() {
        transform = new Transform();
    }

    GameObject(String fname) {
        transform = new Transform();
        setMesh(fname);
        String[] sn = fname.split("\\\\");
        name = sn[sn.length - 1].substring(0, sn[sn.length - 1].length() - 4);
        shader = new Shader(new DepthVertexShader(), new DepthFragmentShader());
    }

    void reset() {
        transform.position.setZero();
        transform.rotation.setZero();
        transform.scale.setOnes();
    }

    void setMesh(String fname) {
        mesh = new Mesh(fname);
    }

    void Draw() {
        Matrix4 MVP = main_camera.Matrix().mult(localToWorld());
        for (int i=0; i<mesh.triangles.size(); i++) {
            Triangle triangle = mesh.triangles.get(i);
            Vector3[] position = triangle.verts;
            Vector4[] gl_Position = shader.vertex.main(new Object[]{position}, new Object[]{MVP});
            Vector3[] s_Position = new Vector3[3];
            for (int j = 0; j<gl_Position.length; j++) {
                s_Position[j] = gl_Position[j].homogenized();
            }
            Vector3[] boundbox = findBoundBox(s_Position);
            float minX = map(min( max(boundbox[0].x, -1.0 ), 1.0), -1.0, 1.0, 0.0, renderer_size.z - renderer_size.x);
            float maxX = map(min( max(boundbox[1].x, -1.0 ), 1.0), -1.0, 1.0, 0.0, renderer_size.z - renderer_size.x);
            float minY = map(min( max(boundbox[0].y, -1.0 ), 1.0), -1.0, 1.0, 0.0, renderer_size.w - renderer_size.y);
            float maxY = map(min( max(boundbox[1].y, -1.0 ), 1.0), -1.0, 1.0, 0.0, renderer_size.w - renderer_size.y);
            
            for (int y = int(minY); y < maxY; y++) {
                for (int x = int(minX); x < maxX; x++) {
                    float rx=map(x, 0.0 , renderer_size.z - renderer_size.x, -1, 1);
                    float ry=map(y, 0.0, renderer_size.w - renderer_size.y, -1, 1);
                    if (!pnpoly(rx, ry, s_Position)) continue;
                    int index = y * int(renderer_size.z - renderer_size.x) + x;
                    
                    float z = getDepth(rx, ry, s_Position );
                    Vector4 c = shader.fragment.main(new Object[]{new Vector3(rx, ry, z)});
                    
                    if (GH_DEPTH[index] > z) {
                        GH_DEPTH[index] = z;
                        renderBuffer.pixels[index] = color(c.x * 255, c.y*255, c.z*255);
                    }
                }
            }
        }        
        update();
    }

    void update() {
    }

    void debugDraw() {
        Matrix4 MVP = main_camera.Matrix().mult(localToWorld());
        for (int i = 0; i < mesh.triangles.size(); i++) {
            Triangle triangle = mesh.triangles.get(i);
            Vector3[] img_pos = new Vector3[3];
            Vector4[] clip_pos = new Vector4[3];

            for (int j = 0; j < 3; j++) { //三角形的三個頂點
                clip_pos[j] = MVP.mult(triangle.verts[j].getVector4(1.0));
                img_pos[j] = clip_pos[j].homogenized(); //這是給backface先計算的
            }

            // 加入 backface 判斷。Eye Space就改成檢查法向量正負就可以了
            Vector3 e1 = Vector3.sub(img_pos[1], img_pos[0]);
            Vector3 e2 = Vector3.sub(img_pos[2], img_pos[0]);
            Vector3 N = Vector3.cross(e1, e2);

            if (N.z <= 0) { //因為有呈上mirror x所以變成<=0才是backface
                continue;  
            }

            //處理完backface(可以有完整的三角形來判斷)，再來處理clipping
            int[][] edges = { {0, 1}, {1, 2}, {2, 0} }; //三個邊都要檢查
            for (int[] edge : edges) {
                Vector4[] clipped = clipLine(clip_pos[edge[0]], clip_pos[edge[1]]);

                if (clipped == null) { //線段都在外面
                    continue;
                }

                Vector3 p1 = clipped[0].homogenized();
                Vector3 p2 = clipped[1].homogenized();

                // 4. map() 轉成 Screen Space 並畫線
                float x1 = map(p1.x, -1, 1, renderer_size.x, renderer_size.z);
                float y1 = map(p1.y, -1, 1, renderer_size.y, renderer_size.w);
                float x2 = map(p2.x, -1, 1, renderer_size.x, renderer_size.z);
                float y2 = map(p2.y, -1, 1, renderer_size.y, renderer_size.w);
                CGLine(x1, y1, x2, y2);
            }

            /*原先程式
            for (int j = 0; j < img_pos.length; j++) {
                img_pos[j] = new Vector3(map(img_pos[j].x, -1, 1, renderer_size.x, renderer_size.z),
                        map(img_pos[j].y, -1, 1, renderer_size.y, renderer_size.w), img_pos[j].z);
            }

            CGLine(img_pos[0].x, img_pos[0].y, img_pos[1].x, img_pos[1].y);
            CGLine(img_pos[1].x, img_pos[1].y, img_pos[2].x, img_pos[2].y);
            CGLine(img_pos[2].x, img_pos[2].y, img_pos[0].x, img_pos[0].y);
            */
        }
    }

    Vector4[] clipLine(Vector4 a, Vector4 b) {

        // 複製端點，避免改到原本的頂點資料
        Vector4 p1 = new Vector4(a.x, a.y, a.z, a.w);
        Vector4 p2 = new Vector4(b.x, b.y, b.z, b.w);

        // 6 個平面的係數 {a, b, c, d}，對應 ax + by + cz + dw >= 0
        float[][] planes = {
            {  1,  0,  0, 1 }, // 左平面：w + x >= 0
            { -1,  0,  0, 1 }, // 右平面：w - x >= 0
            {  0,  1,  0, 1 }, // 下平面：w + y >= 0
            {  0, -1,  0, 1 }, // 上平面：w - y >= 0
            {  0,  0,  1, 0 }, // 近平面：z >= 0
            {  0,  0, -1, 1 }  // 遠平面：w - z >= 0
        };

        for (float[] pl : planes) {
            float c1 = pl[0] * p1.x + pl[1] * p1.y + pl[2] * p1.z + pl[3] * p1.w;
            float c2 = pl[0] * p2.x + pl[1] * p2.y + pl[2] * p2.z + pl[3] * p2.w;

            if (c1 < 0 && c2 < 0) return null; // 兩點都在外面，整條線捨棄
            if (c1 >= 0 && c2 >= 0) continue;  // 兩點都在裡面，換下一個平面檢查

            // 一內一外：照筆記公式算交點並替換在外面那一點
            float t = c1 / (c1 - c2);
            Vector4 intersect = new Vector4(
                p1.x + t * (p2.x - p1.x),
                p1.y + t * (p2.y - p1.y),
                p1.z + t * (p2.z - p1.z),
                p1.w + t * (p2.w - p1.w)
            );

            if (c1 < 0) p1 = intersect;
            else        p2 = intersect;
        }

        return new Vector4[]{ p1, p2 };

    }

    String getGameObjectName() {
        return name;
    }

    Matrix4 localToWorld() { //把模型自己的座標轉換成世界座標。

        // TODO HW3
        // You need to calculate the model Matrix here.

        //return Matrix4.Identity();
        return Matrix4.Trans(transform.position)  //基本上就是下面的matrices 的inverse
        .mult(Matrix4.RotY(transform.rotation.y))
        .mult(Matrix4.RotX(transform.rotation.x))
        .mult(Matrix4.RotZ(transform.rotation.z))
        .mult(Matrix4.Scale(transform.scale));


    }

    Matrix4 worldToLocal() {
        return Matrix4.Scale(transform.scale.inv()).mult(Matrix4.RotZ(-transform.rotation.z))
                .mult(Matrix4.RotX(-transform.rotation.x)).mult(Matrix4.RotY(-transform.rotation.y))
                .mult(Matrix4.Trans(transform.position.mult(-1)));
    }

    Vector3 forward() {
        return (Matrix4.RotZ(transform.rotation.z).mult(Matrix4.RotX(transform.rotation.y))
                .mult(Matrix4.RotY(transform.rotation.x)).zAxis()).mult(-1);
    }
}
