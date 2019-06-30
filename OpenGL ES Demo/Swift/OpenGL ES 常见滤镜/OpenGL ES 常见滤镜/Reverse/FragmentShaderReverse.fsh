
varying lowp vec2 textureCoord;
uniform sampler2D sampler;

void main(){
    gl_FragColor = texture2D(sampler, vec2(textureCoord.x, 1.0 - textureCoord.y));
}


