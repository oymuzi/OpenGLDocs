
varying lowp vec2 textureCoord;
uniform sampler2D sampler;

void main(){
    lowp vec2 uv = vec2(0.0, 0.0);
    if (textureCoord.x < 0.5) {
        uv.x = textureCoord.x + 0.25;
        uv.y = textureCoord.y;
    } else {
        uv.x = textureCoord.x - 0.25;
        uv.y = textureCoord.y;
    }
    gl_FragColor = texture2D(sampler, uv);
}
