#version 300 es

varying lowp vec2 textureCoord;
uniform  sampler2D sampler;

void main(){
  gl_FragColor = texture2D(sampler, textureCoord);
}
