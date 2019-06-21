attribute vec4 position;
attribute vec2 textureCoordinate;
varying lowp vec2 varyTextureCoord;

void main(){
    varyTextureCoord = textureCoordinate;
    gl_Position = position;
}
