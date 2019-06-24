varying lowp vec2 textureCoord;
uniform sampler2D textureSampler;

void main(){
    gl_FragColor = texture2D(textureSampler, textureCoord);
}
