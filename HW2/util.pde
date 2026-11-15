public void CGLine(float x1, float y1, float x2, float y2) {
    // , color save_color 原先我還有新增這個功能，但重改太麻煩了

    /*
     stroke(0);
     noFill();
     line(x1,y1,x2,y2);
    */
    color save_color=color(255,0,0);
    boolean is_flat=false;
    boolean is_neg_x=false;
    float x=x1;
    float y=y1;
    float x_2=x2;
    float y_2=y2;
    
    if(abs(y2 - y1) < abs(x2 - x1)){ //平緩線 交換x,y
        x=y1; x_2=y2;
        y=x1; y_2=x2;
        is_flat=true;
    }
      
    if( y>y_2){  //X軸左右，交換起終點 x1,x2; y1,y2 確保依然是往下走
        float tx=x; float ty=y;  //必須要使用tx, ty不然會又被初始值覆蓋
        x=x_2; x_2=tx;
        y=y_2;y_2=ty;
    }
    if (x > x_2) { //右上左下 確保依然是往右走
        x = -x;
        x_2 = -x_2;
        is_neg_x = true;
    }
    float a=y_2-y;
    float b=x-x_2; //-dx !
    float d=a/2+b;
    while(y<y_2){
        float drawy=y;
        float drawx= is_neg_x ? -x : x;  //畫的時候要復原
        if (!is_flat) {
            drawPoint(drawx, drawy, save_color);
        } else {
            drawPoint(drawy, drawx, save_color);
        }
        if(d>0){ //S
            y++;
            d+=b;
        }else{  //SE
            y++;
            x++;
            d+=(a+b);
        }
    }    
}

public boolean outOfBoundary(float x, float y) {
    if (x < 0 || x >= width || y < 0 || y >= height)
        return true;
    return false;
}

public void drawPoint(float x, float y, color c) {
    int index = (int) y * width + (int) x;
    if (outOfBoundary(x, y))
        return;
    pixels[index] = c;
}

public float distance(Vector3 a, Vector3 b) {
    Vector3 c = a.sub(b);
    return sqrt(Vector3.dot(c, c));
}

boolean pnpoly(float x, float y, Vector3[] vertexes) {
    // TODO HW2 
    // You need to check the coordinate p(x,v) if inside the vertices. 
    // If yes return true, vice versa.
    Vector3[] result = findBoundBox(vertexes);
    float minx=result[0].x; float miny=result[0].y;
    float maxx=result[1].x; float maxy=result[1].y;
    boolean inside=false;
    if(x>maxx || x<minx || y>maxy || y<miny) return false; //提早結束

    int j=vertexes.length-1;
    for(int i=0; i<vertexes.length;i++){
        float xi=vertexes[i].x; float yi=vertexes[i].y;
        float xj=vertexes[j].x; float yj=vertexes[j].y;

        if((y>yi)!=(y>yj)){  //如果沒有通過任何邊，換檢查下一個
            if(yi!=yj){ //水平線就跳過
                float x_intersect = xi + (y - yi) * (xj - xi) / (yj - yi); //計算交會點
                    
                // 如果交點在測試點的左邊，狀態反轉
                if (x > x_intersect){inside = !inside;}
            }
        }
        j=i;
    }
    if(inside) return true;

    return false;
}

public Vector3[] findBoundBox(Vector3[] v) {
    
    // TODO HW2 
    // You need to find the bounding box of the vertices v.
    // r1 -------
    //   |   /\  |
    //   |  /  \ |
    //   | /____\|
    //    ------- r2
    float minx = v[0].x; float miny = v[0].y;
    float maxx = v[0].x; float maxy = v[0].y;
    for(int i=1; i<v.length;i++){
        if(v[i].x>maxx)maxx=v[i].x;
        if(v[i].x<minx)minx=v[i].x;
        if(v[i].y>maxy)maxy=v[i].y;
        if(v[i].y<miny)miny=v[i].y;
    }
    Vector3 recordminV = new Vector3(minx,miny,0);
    Vector3 recordmaxV = new Vector3(maxx,maxy,0);
    Vector3[] result = { recordminV, recordmaxV };
    return result;

}

public Vector3[] Sutherland_Hodgman_algorithm(Vector3[] points, Vector3[] boundary) {
    ArrayList<Vector3> input = new ArrayList<Vector3>();
    ArrayList<Vector3> output = new ArrayList<Vector3>();
    for (int i = 0; i < points.length; i += 1) {
        input.add(points[i]);
    }

    // TODO HW2
    // You need to implement the Sutherland Hodgman Algorithm in this section.
    // The function you pass 2 parameter. One is the vertexes of the shape "points".
    // And the other is the vertices of the "boundary".
    // The output is the vertices of the polygon.

    int j=boundary.length-1;
    for(int i=0;i<boundary.length;i++){ //把每個邊界都算/切一次
        float b1x=boundary[i].x; float b1y=boundary[i].y;  
        float b2x=boundary[j].x; float b2y=boundary[j].y;
        float Bx= b2x-b1x; float By=b2y-b1y;
        int k = 0;

        while (k < input.size()) { //把每個圖形的邊都算一次
            int next = (k + 1) % input.size(); //這樣到n-1會回到0
            Vector3 S = input.get(k);
            Vector3 P = input.get(next);

            float P1x = S.x - b1x;
            float P1y = S.y - b1y;
            float P2x = P.x - b1x;
            float P2y = P.y - b1y;
            //計算他們的cross來分辨是在內部還是外部
            float crossS = Bx * P1y - By * P1x;
            float crossP = Bx * P2y - By * P2x;

            if (crossS >= 0 && crossP >= 0) {// S、P 都在內部:加入P
                output.add(P);

            } else if (crossS >= 0 && crossP < 0) {// S 在內部，P 在外部：加入交點i
                float dx = P.x - S.x;
                float dy = P.y - S.y;
                float denominator = dx * By - dy * Bx; //這是兩條線交點的公式
                float t = ((b1x - S.x) * By - (b1y - S.y) * Bx) / denominator;
                output.add(new Vector3(S.x + t * dx, S.y + t * dy, 0));

            } else if (crossS < 0 && crossP >= 0) {// S 在外部，P 在內部：加入交點，再加入 P
                float dx = P.x - S.x;
                float dy = P.y - S.y;
                float denominator = dx * By - dy * Bx;
                float t = ((b1x - S.x) * By - (b1y - S.y) * Bx) / denominator;

                output.add(new Vector3( S.x + t * dx, S.y + t * dy, 0));
                output.add(P);
            }
            //else就是都在外面就不用做任何事

            k++;
        }
        // 把 output 變成下一輪的 input
        input.clear();
        input.addAll(output);
        output.clear(); // 清空 output
        j=i;
    }
    output =input;

    Vector3[] result = new Vector3[output.size()];
    for (int i = 0; i < result.length; i += 1) {
        result[i] = output.get(i);
    }
    return result;
}
