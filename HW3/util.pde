public void CGLine(float x1, float y1, float x2, float y2) {
    stroke(0);
    line(x1, y1, x2, y2);
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
    // You need to check the coordinate p(x,v) if inside the vertexes.
    Vector3[] result = findBoundBox(vertexes);
    float minx=result[0].x; float miny=result[0].y;
    float maxx=result[1].x; float maxy=result[1].y;
    boolean inside=false;
    if(x>maxx || x<minx || y>maxy || y<miny) return false; //提早結束

    int j=vertexes.length-1;
    for(int i=0;i<vertexes.length;i++){
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
    // You need to find the bounding box of the vertexes v.
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
    // And the other is the vertexes of the "boundary".
    // The output is the vertexes of the polygon.

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

public float getDepth(float x, float y, Vector3[] vertex) {
    // TODO HW3
    // You need to calculate the depth (z) in the triangle (vertex) based on the
    // positions x and y. and return the z value;
    Vector3 v0= Vector3.sub(vertex[1],vertex[0]);
    Vector3 v1= Vector3.sub(vertex[2],vertex[0]);
    Vector3 N= Vector3.cross(v0,v1);  //對應到平面公式ABC
    float D= -(N.x*vertex[0].x+N.y*vertex[0].y+N.z*vertex[0].z);
    if (abs(N.z) < 0.000001f) {
        // 這是退化三角形，應該略過
        return Float.MAX_VALUE;
    }
    float z= (float) -(N.x*x+N.y*y+D)/N.z;

    return z; //然而因為差距小所以灰階看不出來，所以在shader的程式加上增加對比/差距
}

float[] barycentric(Vector3 P, Vector4[] verts) {

    Vector3 A = verts[0].homogenized();
    Vector3 B = verts[1].homogenized();
    Vector3 C = verts[2].homogenized();

    // TODO HW4
    // Calculate the barycentric coordinates of point P in the triangle verts using
    // the barycentric coordinate system.

    float[] result = { 0.0, 0.0, 0.0 };

    return result;
}
