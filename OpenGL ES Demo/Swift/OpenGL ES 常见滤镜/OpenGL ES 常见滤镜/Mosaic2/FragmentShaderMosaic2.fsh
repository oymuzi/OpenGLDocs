precision highp float;
varying lowp vec2 textureCoord;
uniform sampler2D sampler;

// 马赛克大小
const float mosaicSize = 0.03;

void main(){
    
    float length = mosaicSize;
    // 矩形长度
    float TX = 3.0 / 2.0;
    // 矩形高度
    float TY = sqrt(3.0) / 2.0;
    
    float x = textureCoord.x;
    float y = textureCoord.y;
    // 计算出当前矩形在竖向的第几个
    int wx = int(x / TX / length);
    // 计算出当前矩形在横向的第几个
    int wy = int(y / TY / length);
    // 用于记录
    vec2 v1, v2, vn;
    
    // 判断是否为偶数行。不能使用取余来计算会出现错误，当前的作用类似于: wx % 2 == 0
    if (wy / 2 * 2 == wy) {
        if (wx / 2 * 2 == wx){
            // 左下和右上
            v1 = vec2(length * TX * float(wx), length * TY * float(wy));
            v2 = vec2(length * TX * float(wx + 1), length * TY * float(wy + 1));
        } else {
            // 左上和右下
            v1 = vec2(length * TX * float(wx), length * TY * float(wy + 1));
            v2 = vec2(length * TX * float(wx + 1), length * TY * float(wy));
        }
    }
    else {
        if (wx / 2 * 2 == wx){
            // 左上和右下
            v1 = vec2(length * TX * float(wx), length * TY * float(wy + 1));
            v2 = vec2(length * TX * float(wx + 1), length * TY * float(wy));
        } else {
            // 左下和右上
            v1 = vec2(length * TX * float(wx), length * TY * float(wy));
            v2 = vec2(length * TX * float(wx + 1), length * TY * float(wy + 1));
        }
    }

    // 判断当前点离哪个六边形近，就用近的颜色
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


