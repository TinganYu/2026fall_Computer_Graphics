
public class Shape{   
    Vector3[] vertex = new Vector3[0];
    Transform transform = new Transform();
    
    public void drawShape(){                      
        Matrix4 model_matrix = localToWorld();
        Vector3[] t_pos = new Vector3[vertex.length];
        for(int i=0;i<t_pos.length;i++){
            t_pos[i] = model_matrix.mult(vertex[i].getVector4(1)).xyz();                       
        }

        float shapeDepth = t_pos.length > 0 ? t_pos[0].z : 0;
        
        t_pos = Sutherland_Hodgman_algorithm(t_pos,engine.boundary);
        
        for(int i=0;i<t_pos.length;i++){
            t_pos[i] = new Vector3(map(t_pos[i].x,-1,1,20,520),map(t_pos[i].y,-1,1,50,height-50),0);
        }

        Vector3[] minmax = findBoundBox(t_pos);
        
        /* 以下是原本的程式
        loadPixels();       
        for(int i = int(minmax[0].x);i<=minmax[1].x;i++){
            for(int j = int(minmax[0].y);j<=minmax[1].y;j++){
                if(pnpoly(i,j,t_pos)){                    
                    drawPoint(i,j,color(100));
                }
            }
        }
        
             
        for(int i=0;i<t_pos.length;i++){          
            CGLine(t_pos[i].x,t_pos[i].y,t_pos[(i+1)%t_pos.length].x,t_pos[(i+1)%t_pos.length].y); // if you finish it, you can commant this sentance
        }
        updatePixels();

        */

        // Bonus: 對每個像素執行 2 × 2 SSAA sub-pixel sampling。
        for (int i = int(minmax[0].x); i <= int(minmax[1].x); i++) {
            for (int j = int(minmax[0].y); j <= int(minmax[1].y); j++) {
                float[] sampleX = {0.25, 0.75}; //每個像素又分成4等分 sub-pixels
                float[] sampleY = {0.25, 0.75};

                for (int sy = 0; sy < 2; sy++) {
                    for (int sx = 0; sx < 2; sx++) {
                        if (pnpoly(i + sampleX[sx], j + sampleY[sy], t_pos)) {
                            int sampleNumber = sy * 2 + sx;
                            engine.writeSSAA(i + sampleX[sx],
                                             j + sampleY[sy],
                                             sampleNumber,
                                             shapeDepth,
                                             color(100));
                        }
                    }
                }
            }
        }
    };
    
    public Matrix4 localToWorld(){
        return Matrix4.Trans(transform.position).mult(Matrix4.RotZ(transform.rotation.z)).mult(Matrix4.Scale(transform.scale));
    }
    
    public String getShapeName(){
        return "";
    }
    
}

public class Rectangle extends Shape{
    
    public Rectangle(){
        vertex = new Vector3[]{new Vector3(-0.1,-0.1,0),new Vector3(-0.1,0.1,0),new Vector3(0.1,0.1,0),new Vector3(0.1,-0.1,0)};    
    }
    @Override
    public String getShapeName(){
        return "Rectangle";
    }
    
   
}

public class Star extends Shape{
    
    public Star(){
        vertex = new Vector3[]{new Vector3(0.1,0,0),new Vector3(0.0309,0.02244,0),
                               new Vector3(0.0309,0.0951,0),new Vector3(-0.01195,0.03637,0),
                               new Vector3(-0.0809,0.05877,0),new Vector3(-0.03834,0.0002,0),
                               new Vector3(-0.0809,-0.05811,0),new Vector3(-0.012,-0.03599,0),
                               new Vector3(0.0309,-0.0951,0),new Vector3(0.0309,-0.02219,0)};    

    }
    @Override
    public String getShapeName(){
        return "Star";
    }
    
   
}


public class Line extends Shape{
    Vector3 point1;
    Vector3 point2;
    
    public Line(){};
    public Line(Vector3 v1,Vector3 v2){
        point1 = v1;
        point2 = v2;
    }
    
    @Override
    public void drawShape(){
        CGLine(point1.x,point1.y,point2.x,point2.y);
    }
    
   
}



public class Polygon extends Shape{
    ArrayList<Vector3> verties = new ArrayList<Vector3>();
     public Polygon(ArrayList<Vector3> v){
        verties= v;
    }
    
    @Override
    public void drawShape(){
        if(verties.size()<=0) return;
        for(int i=0;i<=verties.size();i++){
              Vector3 p1 = verties.get(i%verties.size());
              Vector3 p2 = verties.get((i+1)%verties.size());
              CGLine(p1.x,p1.y,p2.x,p2.y);
         }
    } 
}
