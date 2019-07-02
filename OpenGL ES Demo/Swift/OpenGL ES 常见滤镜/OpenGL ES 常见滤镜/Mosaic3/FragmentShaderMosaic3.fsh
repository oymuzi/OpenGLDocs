precision highp float;
varying lowp vec2 textureCoord;
uniform sampler2D sampler;

const float mosaicSize = 0.03;
const float PI6 = 0.62831852;

void main(){
    
    float length = mosaicSize;
    float TX = 3.0 / 2.0;
    float TY = sqrt(3.0) / 2.0;
    
    float x = textureCoord.x;
    float y = textureCoord.y;
    
    int wx = int(x / TX / length);
    int wy = int(y / TY / length);
    
    vec2 v1, v2, vn;
    
    if (wx / 2 * 2 == wx) {
        if (wy / 2 * 2 == wy){
            v1 = vec2(length * TX * float(wx + 1), length * TY * float(wy));
            v2 = vec2(length * TX * float(wx), length * TY * float(wy + 1));
        } else {
            v1 = vec2(length * TX * float(wx + 1), length * TY * float(wy + 1));
            v2 = vec2(length * TX * float(wx), length * TY * float(wy));
        }
    }
    else {
        if (wy / 2 * 2 == wy){
            v1 = vec2(length * TX * float(wx + 1), length * TY * float(wy + 1));
            v2 = vec2(length * TX * float(wx), length * TY * float(wy));
        } else {
            v1 = vec2(length * TX * float(wx + 1), length * TY * float(wy));
            v2 = vec2(length * TX * float(wx), length * TY * float(wy + 1));
        }
    }
    
    float s1 = sqrt(pow(v1.x - x, 2.0) + pow(v1.y - y, 2.0));
    float s2 = sqrt(pow(v2.x - x, 2.0) + pow(v2.y - y, 2.0));
    
    if (s1 < s2){
        vn = v1;
    } else {
        vn = v2;
    }
    
    vec4 midColor = texture2D(sampler, vn);
    
    float a = atan((x - vn.x) / (y - vn.y));
    vec2 area1 = vec2(vn.x, vn.y - mosaicSize * TY / 2.0);
    vec2 area2 = vec2(vn.x + mosaicSize / 2.0, vn.y - mosaicSize * TY / 2.0);
    vec2 area3 = vec2(vn.x + mosaicSize / 2.0, vn.y + mosaicSize * TY / 2.0);
    vec2 area4 = vec2(vn.x, vn.y + mosaicSize * TY / 2.0);
    vec2 area5 = vec2(vn.x - mosaicSize / 2.0, vn.y + mosaicSize * TY / 2.0);
    vec2 area6 = vec2(vn.x - mosaicSize / 2.0, vn.y - mosaicSize * TY / 2.0);

    if (a >= PI6 && a < PI6 * 3.0) {
        vn = area1;
    } else if (a >= PI6 * 3.0 && a < PI6 * 5.0) {
        vn = area2;
    } else if ((a >= PI6 * 5.0 && a <= PI6 * 6.0) || (a < -PI6 * 5.0 && a > -PI6 * 6.0)) {
        vn = area3;
    } else if (a < -PI6 * 3.0 && a >= -PI6 * 5.0) {
        vn = area4;
    } else if(a <= -PI6 && a> -PI6 * 3.0) {
        vn = area5;
    } else if (a > -PI6 && a < PI6) {
        vn = area6;
    }
    
    vec4 color = texture2D(sampler, vn);
    
    gl_FragColor = color;
}



