varying lowp vec2 varyTextureCoord;
uniform sampler2D colorMap;

void main(){
    lowp vec2 rightTextureCoord = vec2(varyTextureCoord.x, 1.0 - varyTextureCoord.y);
    gl_FragColor = texture2D(colorMap, rightTextureCoord);
}
