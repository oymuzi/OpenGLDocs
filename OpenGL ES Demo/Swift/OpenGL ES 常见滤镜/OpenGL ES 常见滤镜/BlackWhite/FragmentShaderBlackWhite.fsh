precision highp float;
varying vec2 textureCoord;
uniform sampler2D sampler;

void main(){
    vec4 mask = texture2D(sampler, textureCoord);
    float color = (mask.r + mask.g + mask.b) / 3.0;
    gl_FragColor = vec4(color, color, color, 1.0);
}
