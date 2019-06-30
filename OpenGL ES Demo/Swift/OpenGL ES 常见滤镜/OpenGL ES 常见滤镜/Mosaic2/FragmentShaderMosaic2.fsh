precision highp float;
varying lowp vec2 textureCoord;
uniform sampler2D sampler;

// 马赛克大小
const float mosaicSize = 0.03;

void main(){
    
    float length = mosaicSize;
    float TX = 1.5;
    float TY = 0.866025;
    
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

    vec4 color = texture2D(sampler, vn);
    
    gl_FragColor = color;
}


