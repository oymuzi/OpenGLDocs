varying lowp vec2 textureCoord;
uniform sampler2D sampler;

void main(){
    lowp vec2 uv = vec2(0.0, 0.0);
    if (textureCoord.x < 0.5) {
        if (textureCoord.y < 0.5) {
            uv.x = textureCoord.x * 2.0;
            uv.y = textureCoord.y * 2.0;
        } else {
            uv.x = textureCoord.x * 2.0;
            uv.y = (textureCoord.y - 0.5) * 2.0;
        }
    } else {
        if (textureCoord.y < 0.5) {
            uv.x = (textureCoord.x - 0.5) * 2.0;
            uv.y = textureCoord.y * 2.0;
        } else {
            uv.x = (textureCoord.x - 0.5) * 2.0;
            uv.y = (textureCoord.y - 0.5) * 2.0;
        }
    }
    gl_FragColor = texture2D(sampler, uv);
}
