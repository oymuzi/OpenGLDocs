precision highp float;
varying lowp vec2 textureCoord;
uniform sampler2D sampler;

uniform float time;

void main(){
    float duration = 0.75;
    float maxScale = 1.2;
    float offset = 0.04;
    
    float progress = mod(time, duration) / duration;
    vec2 offsetCoord = vec2(offset, offset) * progress;
    float scale = 1.0 + (maxScale - 1.0) * progress;
    
    vec2 shakeCoord = vec2(0.5, 0.5) + (textureCoord - vec2(0.5, 0.5)) / scale;
    
    vec4 maskR = texture2D(sampler, shakeCoord - offsetCoord);
    vec4 maskB = texture2D(sampler, shakeCoord + offsetCoord);
    vec4 mask = texture2D(sampler, shakeCoord);
    
    gl_FragColor = vec4(maskR.r, mask.g, maskB.b, mask.a);
    
}



