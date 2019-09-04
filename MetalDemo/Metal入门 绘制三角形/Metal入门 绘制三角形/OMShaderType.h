//
//  OMShaderType.h
//  Metal入门 绘制三角形
//
//  Created by 欧阳林 on 2019/7/6.
//  Copyright © 2019年 欧阳林. All rights reserved.
//

#ifndef OMShaderType_h
#define OMShaderType_h

#include <simd/simd.h>

typedef enum{
    // 顶点索引
    OMInputIndexVertexs = 0,
    // 视图大小
    OMInputIndexViewportSize = 1
}OMInputIndex;

typedef struct{
    // 位置
    vector_float2 position;
    // 颜色值
    vector_float4 color;
}OMVertexs;


#endif /* OMShaderType_h */
