public void CGLine(float x1, float y1, float x2, float y2, color save_color) {
    // TODO HW1
    // You need to implement the "line algorithm" in this section.
    // You can use the function line(x1, y1, x2, y2); to verify the correct answer.
    // However, remember to comment out before you submit your homework.
    // Otherwise, you will receive a score of 0 for this part.
    // Utilize the function drawPoint(x, y, color) to apply color to the pixel at
    // coordinates (x, y).
    // For instance: drawPoint(114, 514, color(255, 0, 0)); signifies drawing a red
    // point at (114, 514).

    /*
     stroke(0);
     noFill();
     line(x1,y1,x2,y2);
    */
    
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
    while(y!=y_2){
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

public void CGCircle(float x, float y, float r, color save_color) {
    // TODO HW1
    // You need to implement the "circle algorithm" in this section.
    // You can use the function circle(x, y, r); to verify the correct answer.
    // However, remember to comment out before you submit your homework.
    // Otherwise, you will receive a score of 0 for this part.
    // Utilize the function drawPoint(x, y, color) to apply color to the pixel at
    // coordinates (x, y).
    // x,y is the first point, r is the radius that will keep changing.
    /*
    stroke(0);
    noFill();
    circle(x,y,r*2);
    */
    
    float offsetx = 0; //因為課本公式是以(0,0)為原點，所以用offset取代x,y
    float offsety = r;
    float d = 1.25f - r; //用5/4會整除

    while(offsetx <= offsety){
        drawPoint(x+offsetx, y+offsety, save_color);
        drawPoint(x+offsetx, y-offsety, save_color);
        drawPoint(x-offsetx, y-offsety, save_color);
        drawPoint(x-offsetx, y+offsety, save_color);
        drawPoint(x+offsety, y+offsetx, save_color);
        drawPoint(x+offsety, y-offsetx, save_color);
        drawPoint(x-offsety, y+offsetx, save_color);
        drawPoint(x-offsety, y-offsetx, save_color);
        if(d<0){
            d += 2 * offsetx + 3;
            offsetx++;
        }else{
            d += 2 * (offsetx - offsety) + 5;
            offsetx++;
            offsety--;
        }
    }
    
}

public void CGEllipse(float x, float y, float r1, float r2, color save_color) {
    // TODO HW1
    // You need to implement the "ellipse algorithm" in this section.
    // You can use the function ellipse(x, y, r1,r2); to verify the correct answer.
    // However, remember to comment out the function before you submit your homework.
    // Otherwise, you will receive a score of 0 for this part.
    // Utilize the function drawPoint(x, y, color) to apply color to the pixel at
    // coordinates (x, y).

    /*
    stroke(0);
    noFill();
    ellipse(x,y,r1*2,r2*2);
    */
    //好像助教程式已經寫好了，還沒回傳第二點之前r1=r2=r
    //從參考網址改程式
    float dx, dy, d1, d2, xp, yp;
    xp = 0;
    yp = r2;

    // 陡峭區域
    d1 = (r2 * r2) - (r1 * r1 * r2) + (0.25 * r1 * r1);
    dx = 2 * r2 * r2 * xp;
    dy = 2 * r1 * r1 * yp;

    while (dx < dy) {
        drawPoint(xp + x, yp + y, save_color);
        drawPoint(-xp + x, yp + y, save_color);
        drawPoint(xp + x, -yp + y, save_color);
        drawPoint(-xp + x, -yp + y, save_color);
        if (d1 < 0){
                xp++;
                dx = dx + (2 * r2 * r2);
                d1 = d1 + dx + (r2 * r2);
        }else{
            xp++;
            yp--;
            dx = dx + (2 * r2 * r2);
            dy = dy - (2 * r1 * r1);
            d1 = d1 + dx - dy + (r2 * r2);
        }
    }

    // 平滑區域
    d2 = ((r2 * r2) * ((xp + 0.5) * (xp + 0.5))) + ((r1 * r1) * ((yp - 1) * (yp - 1))) - (r1 * r1 * r2 * r2);

    while (yp >= 0){ 
        drawPoint(xp + x, yp + y, save_color);
        drawPoint(-xp + x, yp + y, save_color);
        drawPoint(xp + x, -yp + y, save_color);
        drawPoint(-xp + x, -yp + y, save_color);
        if (d2 > 0) {
            yp--;
            dy = dy - (2 * r1 * r1);
            d2 = d2 + (r1 * r1) - dy;
        }else{
            yp--;
            xp++;
            dx = dx + (2 * r2 * r2);
            dy = dy - (2 * r1 * r1);
            d2 = d2 + dx - dy + (r1 * r1);
        }
    }
}

    

public void CGCurve(Vector3 p1, Vector3 p2, Vector3 p3, Vector3 p4, color save_color) {
    // TODO HW1
    // You need to implement the "bezier curve algorithm" in this section.
    // You can use the function bezier(p1.x, p1.y, p2.x, p2.y, p3.x, p3.y, p4.x,
    // p4.y); to verify the correct answer.
    // However, remember to comment out before you submit your homework.
    // Otherwise, you will receive a score of 0 for this part.
    // Utilize the function drawPoint(x, y, color) to apply color to the pixel at
    // coordinates (x, y).
    /*
        if(times == 1) CGCurve(cp1, cp1, cp, cp);
        if(times == 2) CGCurve(cp1, cp, cp2, cp2);
        if(times == 3) CGCurve(cp1, cp3, cp, cp2);
    */

    /*
    stroke(0);
    noFill();
    bezier(p1.x,p1.y,p2.x,p2.y,p3.x,p3.y,p4.x,p4.y);
    */
    for (float t = 0; t <= 1; t += 0.001f) {  //這邊要記得改成float移動，不然只有 t=0,1
        float min_t = 1 - t;
        float xp = pow(min_t, 3) * p1.x()
            + 3 * pow(min_t, 2) * t * p2.x()
            + 3 * min_t * pow(t, 2) * p3.x()
            + pow(t, 3) * p4.x();
        float yp = pow(min_t, 3) * p1.y()
            + 3 * pow(min_t, 2) * t * p2.y()
            + 3 * min_t * pow(t, 2) * p3.y()
            + pow(t, 3) * p4.y();
        drawPoint(xp,yp, save_color);
    }
}

public void CGEraser(Vector3 p1, Vector3 p2) {
    // TODO HW1
    // You need to erase the scene in the area defined by points p1 and p2 in this
    // section.
    // p1 ------
    // |       |
    // |       |
    // ------ p2
    // The background color is color(250);
    // You can use the mouse wheel to change the eraser range.
    // Utilize the function drawPoint(x, y, color) to apply color to the pixel at
    // coordinates (x, y).

    float xp=p1.x();
    float yp=p1.y();
    for(xp=p1.x();xp<=p2.x();xp++){
            for(yp=p1.y();yp<=p2.y();yp++){
            drawPoint(xp, yp, color(250));
        }
    }
    

}

public void drawPoint(float x, float y, color c) {
    stroke(c);
    point(x, y);
}

public float distance(Vector3 a, Vector3 b) {
    Vector3 c = a.sub(b);
    return sqrt(Vector3.dot(c, c));
}
