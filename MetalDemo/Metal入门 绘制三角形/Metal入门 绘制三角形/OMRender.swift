//
//  OMRender.swift
//  Metal入门 绘制三角形
//
//  Created by 欧阳林 on 2019/7/6.
//  Copyright © 2019年 欧阳林. All rights reserved.
//

import UIKit
import MetalKit


//enum OMInputIndex: Int{
//    // 顶点索引
//    case OMInputIndexVertexs = 0
//    // 视图大小索引
//    case OMInputIndexViewportSize = 1
//}

//struct OMVertexs{
//    // 位置
//    var position: vector_float2
//    // 颜色值
//    var color: vector_float4
//}

class OMRender: NSObject {
    
    private var device: MTLDevice!
    
    private var commandQueue: MTLCommandQueue!
    // 渲染管线
    private var pipelineState: MTLRenderPipelineState!
    // 视口大小
    private var viewportSize: vector_uint2 = vector_uint2(UInt32(UIScreen.main.bounds.width), UInt32(UIScreen.main.bounds.height))
    
    
    private override init(){
        super.init()
    }
    
    public init(mtkView: MTKView){
        guard let device = mtkView.device else {
            print("当前设备不支持当前渲染")
            return
        }
        
        self.device = device
        
        // 加载所有的.metal文件
        let defaultLibrary = device.makeDefaultLibrary()
        // 加载顶点函数
        let vertexFunction = defaultLibrary?.makeFunction(name: "vertexShader")
        // 加载片段函数
        let fragmentFunction = defaultLibrary?.makeFunction(name: "fragmentShader")
        
        
        // 创建渲染管道描述符
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor.init()
        pipelineStateDescriptor.label = "my pipelineStateDescriptor"
        pipelineStateDescriptor.vertexFunction = vertexFunction
        pipelineStateDescriptor.fragmentFunction = fragmentFunction
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = mtkView.colorPixelFormat
        
        // 创建渲染管线
        pipelineState = try? self.device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        
        self.commandQueue = device.makeCommandQueue()
    }

}

extension OMRender: MTKViewDelegate{
    
    func draw(in view: MTKView) {
        
        let triangles: [OMVertexs] = [
            
            OMVertexs.init(position: vector_float2(250, -250), color: vector_float4(1, 0, 0, 1)),
            OMVertexs.init(position: vector_float2(-250, -250), color: vector_float4(0, 1, 0, 1)),
            OMVertexs.init(position: vector_float2(0, 250), color: vector_float4(0, 0, 1, 1))
            
        ]
        guard let commandBuffer = commandQueue.makeCommandBuffer() else { return }
        commandBuffer.label = "my commandBuffer"
        
        guard let renderPassdescriptor = view.currentRenderPassDescriptor else { return }
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassdescriptor)
        renderEncoder?.label = "my renderEncoder"
        // 视口指定Metal渲染内容的drawable区域，视口具有x和y偏移，宽度和高度以及远近平面的3D区域，为管道分配自定义视口需要通过调用setViewport方法
        let viewPort = MTLViewport.init(originX: 0.0, originY: 0.0, width: Double(viewportSize.x), height: Double(viewportSize.y), znear: -1.0, zfar: 1.0)
        renderEncoder?.setViewport(viewPort)
        
        // 设置当前渲染管道对象
        renderEncoder?.setRenderPipelineState(pipelineState)
        
        // 发送顶点+颜色数据给Metal顶点着色器
        renderEncoder?.setVertexBytes(triangles, length: MemoryLayout<OMVertexs>.size * triangles.count, index: Int(OMInputIndexVertexs.rawValue))
        // viewport 数据
        renderEncoder?.setVertexBytes(&self.viewportSize, length: MemoryLayout.size(ofValue: self.viewportSize), index: Int(OMInputIndexViewportSize.rawValue))
        
        // 画出三角形的三个顶点, 图元类型有点、线段、线环、三角形、三角形扇
        renderEncoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3)
        
        // 表示该渲染过程生成的命令都已经完成，并且从NTLCommandBuffer中分离
        renderEncoder?.endEncoding()
        
        // 一旦缓冲区完成，使用当前可绘制的进度表
        guard let currentDrawable = view.currentDrawable else { return }
        commandBuffer.present(currentDrawable)
        commandBuffer.commit()
        
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        viewportSize.x = UInt32(size.width)
        viewportSize.y = UInt32(size.height)
    }
}
