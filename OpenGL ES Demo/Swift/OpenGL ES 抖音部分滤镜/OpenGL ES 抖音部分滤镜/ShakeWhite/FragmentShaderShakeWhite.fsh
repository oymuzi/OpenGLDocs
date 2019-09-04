precision highp float;
varying lowp vec2 textureCoord;
uniform sampler2D sampler;

uniform float time;
const float PI = 3.1415926;

void main(){
    
    float duration = 0.75;
    float currentTime = mod(time, duration);
    
    vec4 whiteMask = vec4(1.0, 1.0, 1.0, 1.0);
    float amplitude = abs(currentTime * sin(PI / duration));
    
    vec4 mask = texture2D(sampler, textureCoord);
    
    
    gl_FragColor = mask * (1.0 - amplitude) + whiteMask *amplitude;
}


