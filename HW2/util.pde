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

    Vector3 recordminV = new Vector3(0);
    Vector3 recordmaxV = new Vector3(999);
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

    output = input;

    Vector3[] result = new Vector3[output.size()];
    for (int i = 0; i < result.length; i += 1) {
        result[i] = output.get(i);
    }
    return result;
}
