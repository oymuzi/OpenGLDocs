
precision highp float;
varying vec2 textureCoord;
uniform sampler2D sampler;

const float PI = 3.1415926;
const float angle = 80.0;
const float radius = 0.3;

void main(){
    
    // 旋转正方形范围
    vec2 rectSize = vec2(0.5, 0.5);
    // 旋转区域的内切圆直径
    float votexDiameter = rectSize.s;
    // 纹理坐标
    vec2 st = textureCoord;
    float votexRadius = votexDiameter * radius;
    vec2 textureCoordinate = st * votexDiameter;
    vec2 textureCoordinateHalf = textureCoordinate - vec2(votexDiameter / 2.0, votexDiameter / 2.0);
    float r = length(textureCoordinateHalf);
    float factor = atan(textureCoordinateHalf.y, textureCoordinateHalf.x) + radians(angle) * 2.0 * (1.0 - (r / votexRadius) * (r / votexRadius));
    
    if (r < votexRadius){
        textureCoordinate = votexDiameter * 0.5 + r * vec2(cos(factor), sin(factor));
    }
    
    st = textureCoordinate / votexDiameter;
    vec3 irgb = texture2D(sampler, st).rgb;
    
    
    
    gl_FragColor = vec4(irgb, 1.0);
}


