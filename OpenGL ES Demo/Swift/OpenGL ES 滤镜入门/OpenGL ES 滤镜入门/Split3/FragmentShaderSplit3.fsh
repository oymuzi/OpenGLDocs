
varying lowp vec2 textureCoord;
uniform sampler2D sampler;

void main(){
    lowp vec2 uv = vec2(0.0, 0.0);
    if (textureCoord.y < 1.0/3.0) {
        uv.x = textureCoord.x;
        uv.y = textureCoord.y + 1.0/3.0;
    } else if (textureCoord.y > 2.0/3.0){
        uv.x = textureCoord.x;
        uv.y = textureCoord.y - 1.0/3.0;
    } else {
        uv.x = textureCoord.x;
        uv.y = textureCoord.y;
    }
    gl_FragColor = texture2D(sampler, uv);
}
