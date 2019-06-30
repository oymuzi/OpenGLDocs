
varying lowp vec2 textureCoord;
uniform sampler2D sampler;

void main(){
    lowp vec2 uv = vec2(0.0, 0.0);
    if (textureCoord.x < 1.0 / 3.0) {
        if (textureCoord.y < 0.5) {
            uv.x = textureCoord.x + 0.25;
            uv.y = textureCoord.y * 2.0;
        } else {
            uv.x = textureCoord.x + 0.25;
            uv.y = (textureCoord.y - 0.5) * 2.0;
        }
    } else if (textureCoord.x > 2.0 / 3.0) {
        if (textureCoord.y < 0.5) {
            uv.x = textureCoord.x - 5.0 / 12.0;
            uv.y = textureCoord.y * 2.0;
        } else {
            uv.x = textureCoord.x - 5.0 / 12.0;
            uv.y = (textureCoord.y - 0.5) * 2.0;
        }
    } else {
        if (textureCoord.y < 0.5) {
            uv.x = textureCoord.x - 1.0 / 12.0;
            uv.y = textureCoord.y * 2.0;
        } else {
            uv.x = textureCoord.x - 1.0 / 12.0;
            uv.y = (textureCoord.y - 0.5) * 2.0;
        }
    }
    gl_FragColor = texture2D(sampler, uv);
}
