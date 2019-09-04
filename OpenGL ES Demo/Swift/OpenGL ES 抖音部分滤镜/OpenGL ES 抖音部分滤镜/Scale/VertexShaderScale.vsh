
attribute vec4 position;
attribute vec2 textureCoordinate;
varying lowp vec2 textureCoord;

uniform float time;
const float PI = 3.1415926;

void main(){
    
    // 缩放市场
    float duration = 0.6;
    // 缩放幅度
    float amplitude = 0.25;
    // 周期
    float period = mod(time, duration);
    // 当前幅度 [1, 1.25]
    float currentAmplitude = 1.0 + amplitude * (sin(time * (PI / duration)));
    // 纹理坐标
    textureCoord = textureCoordinate;
    gl_Position = vec4(position.x * currentAmplitude, position.y * currentAmplitude, position.z, position.w);
}


