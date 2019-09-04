//
//  OMShaders.metal
//  Metal入门 绘制三角形
//
//  Created by 欧阳林 on 2019/7/6.
//  Copyright © 2019年 欧阳林. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

#include "OMShaderType.h"

// 顶点着色器输出和片段着色器输入
typedef struct{
    // 顶点信息
    float4 clicpColorPosiiton [[position]];
    // 颜色
    float4 color;
}RasterizaerData;

vertex RasterizaerData vertexShader(uint vertexID [[vertex_id]],
                                    constant OMVertexs *vertecis [[buffer(OMInputIndexVertexs)]],
                                    constant vector_uint2 *aviewPortSize [[buffer(OMInputIndexViewportSize)]]){
    RasterizaerData out;
    out.clicpColorPosiiton = vector_float4(0.0, 0.0, 0.0, 1.0);
    // 索引数组当前顶点
    float2 pixelSpacePosition = vertecis[vertexID].position.xy;
    // 将视口的单位转为vector_float2
    vector_float2 viewPortSize = vector_float2(*aviewPortSize);
    //
    out.clicpColorPosiiton.xy = pixelSpacePosition / (viewPortSize.xy / 2.0);
    out.color = vertecis[vertexID].color;
    
    return out;
}


fragment float4 fragmentShader(RasterizaerData in [[stage_in]]){
    return in.color;
}
