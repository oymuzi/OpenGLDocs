precision highp float;
varying lowp vec2 textureCoord;
uniform sampler2D sampler;

vec2 imageSize = vec2(400.0, 400.0);
vec2 mosaicSize = vec2(10.0, 10.0);

void main(){
    
    // 计算图像实际位置
    vec2 position = vec2(textureCoord.x * imageSize.x, textureCoord.y * imageSize.y);
    // 计算一个小马赛克的位置
    vec2 mosaicPosition = vec2(floor(position.x / mosaicSize.x) * mosaicSize.x, floor(position.y / mosaicSize.y) * mosaicSize.y);
    // 换算纹理坐标
    vec2 texPosition = vec2(mosaicPosition.x / imageSize.x, mosaicPosition.y / imageSize.y);
    vec4 color = texture2D(sampler, texPosition);
    
    gl_FragColor = color;
}

