varying lowp vec2 varyTextureCoord;
uniform sampler2D colorMap;

void main(){
    gl_FragColor = texture2D(colorMap, varyTextureCoord);
}
