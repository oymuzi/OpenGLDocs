precision highp float;
varying lowp vec2 textureCoord;
uniform sampler2D sampler;

uniform float time;

void main(){
    
    float duration = 0.7;
    float maxAlpha = 0.4;
    float maxScale = 1.8;
    
    float progress = mod(time, duration) / duration;
    float alpha = maxAlpha * (1.0 - progress);
    float scale = 1.0 + progress * (maxScale - 1.0);
    
    float sx = 0.5 + (textureCoord.x - 0.5) / scale;
    float sy = 0.5 + (textureCoord.y - 0.5) / scale;
    
    vec2 coord = vec2(sx, sy);
    vec4 mask = texture2D(sampler, coord);
    vec4 origin = texture2D(sampler, textureCoord);
    
    
    gl_FragColor = origin * (1.0 - alpha) + mask * alpha;
}


