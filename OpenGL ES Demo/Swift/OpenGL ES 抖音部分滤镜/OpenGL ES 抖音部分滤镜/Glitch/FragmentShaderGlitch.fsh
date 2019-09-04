precision highp float;
varying lowp vec2 textureCoord;
uniform sampler2D sampler;

uniform float time;
const float PI = 3.1415926;

float rand(float n) {
    // fract(x) 返回x的小数部分数值
    return fract(sin(n) * 50000.0);
}

void main(){
    
    float maxJitter = 0.06;
    float duration = 0.35;
    float colorROffset = 0.025;
    float colorBOffset = -0.025;
    
    float currentTime = mod(time, duration * 2.0);
    float amplitude = max(sin(currentTime * (PI / duration)), 0.0);
    
    float jitter = rand(textureCoord.y) * 2.0 - 1.0;
    bool needOffset = abs(jitter) < maxJitter * amplitude;
    
    float textureX = textureCoord.x + (needOffset ? jitter : (jitter * amplitude * 0.006));
    vec2 textureCoords = vec2(textureX, textureCoord.y);
    
    vec4 mask = texture2D(sampler, textureCoords);
    vec4 maskR = texture2D(sampler, textureCoords + vec2(colorROffset * amplitude, 0.0));
    vec4 maskB = texture2D(sampler, textureCoords + vec2(colorBOffset * amplitude, 0.0));
    
    gl_FragColor = vec4(maskR.r, mask.g, maskB.b, mask.a);
}



