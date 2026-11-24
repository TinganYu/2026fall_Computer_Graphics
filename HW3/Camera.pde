public class Camera {
    Matrix4 projection = new Matrix4();
    Matrix4 worldView = new Matrix4();
    int wid;
    int hei;
    float near;
    float far;
    Transform transform;

    Camera() {
        wid = 256;
        hei = 256;
        worldView.makeIdentity();
        projection.makeIdentity();
        transform = new Transform();
    }

    Matrix4 inverseProjection() {
        Matrix4 invProjection = Matrix4.Zero();
        float a = projection.m[0];
        float b = projection.m[5];
        float c = projection.m[10];
        float d = projection.m[11];
        float e = projection.m[14];
        invProjection.m[0] = 1.0f / a;
        invProjection.m[5] = 1.0f / b;
        invProjection.m[11] = 1.0f / e;
        invProjection.m[14] = 1.0f / d;
        invProjection.m[15] = -c / (d * e);
        return invProjection;
    }

    Matrix4 Matrix() {
        return projection.mult(worldView);
    }

    void setSize(int w, int h, float n, float f) {
        wid = w;
        hei = h;
        near = n;
        far = f;
        
        // TODO HW3 把 3D 相機座標轉成可以畫到 2D 螢幕上的座標
        // This function takes four parameters, which are 
        // the width of the screen, the height of the screen
        // the near plane and the far plane of the camera.
        // Where GH_FOV has been declared as a global variable.
        // Finally, pass the result into projection matrix.

        projection = Matrix4.Identity();
        float fovRadians = radians(GH_FOV) / 2.0f; //GH_FOV是視角，所以要轉換成弧度才可以後續使用tan()。並且注意到只有一半。
        float aspectRatio =(float) w/h;

        projection.m[5]=aspectRatio;
        projection.m[10]=(far/(far-near))*tan(fovRadians);
        projection.m[11]=(far*near/(near-far))*tan(fovRadians);
        projection.m[14]=tan(fovRadians);
        projection.m[15] = 0.0f;

    }

    void setPositionOrientation(Vector3 pos, float rotX, float rotY) {

    }

    void setPositionOrientation(Vector3 pos, Vector3 lookat) {
        // TODO HW3
        // This function takes two parameters, which are the position of the camera and
        // the point the camera is looking at.
        // We uses topVector = (0,1,0) to calculate the eye matrix.
        // Finally, pass the result into worldView matrix.
        Vector3 topVector = new Vector3(0, 1, 0);
        Vector3 viewVector = Vector3.sub(lookat, pos);
        viewVector.normalize();

        Vector3 V1 = Vector3.cross(topVector, viewVector);
        V1.normalize();
        Vector3 V2 = Vector3.cross(viewVector, V1);
        V2.normalize();
        Matrix4 GRM = Matrix4.Identity();
        GRM.m[0] = V1.x;
        GRM.m[1] = V1.y;
        GRM.m[2] = V1.z;

        GRM.m[4] = V2.x;
        GRM.m[5] = V2.y;
        GRM.m[6] = V2.z;

        GRM.m[8] = viewVector.x;
        GRM.m[9] = viewVector.y;
        GRM.m[10] = viewVector.z;

        Matrix4 mirrorX = Matrix4.Identity();
        mirrorX.m[0] =-1.0f;

        worldView = mirrorX
    .mult(GRM)
    .mult(Matrix4.Trans(pos.mult(-1)));
    }
}
