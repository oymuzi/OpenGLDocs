#version 300 es

attribute vec4 position;
attribute vec2 textureCoordinate;
varying lowp vec2 textureCoord;

void main(){
  textureCoord = textureCoordinate;
  gl_Position = position;
}
