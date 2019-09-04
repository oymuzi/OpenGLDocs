//
//  OMRender.swift
//  Metal 入门
//
//  Created by 欧阳林 on 2019/7/6.
//  Copyright © 2019年 欧阳林. All rights reserved.
//

import UIKit
import MetalKit


/// 之所以使用自定义的类来实现Metal的程序是因为可以区分渲染循环，便于管理，以及更好的处理代理回调等

class OMRender: NSObject {
    
    // 设备，在iOS中都是指GPU
    private var device: MTLDevice!
    // 命令队列，从MTKView中获取
    private var commandQueue: MTLCommandQueue!
    
    
    /// 私有化默认初始化方法
    private override init(){
        super.init()
    }
    
    /// 使用一个MTKView来进行实例化
    ///
    /// - Parameter mtkView: MTKView实例
    init(mtkView: MTKView){
        super.init()
        
        guard let device = mtkView.device else {
            print("初始化渲染循环失败，无法获取设备")
            return
        }
        self.device = device
        // 所有Metal程序需要与GPU打交道的第一个类就是MTKCommandQueue，因为只有使用这个加入到MTKCommandBuffer中才能使命令可以按顺序发送给GPU后执行
        self.commandQueue = device.makeCommandQueue()
        
    }
    
}


// MARK: - 区分渲染循环来单独管理代理方法
extension OMRender: MTKViewDelegate{
    
    private struct Color{
        var red: Double
        var blue: Double
        var green: Double
        var alpha: Double
    }
    
    private func makeColor() -> Color{
        let red = Double(arc4random() % 255) / 255.0
        let green = Double(arc4random() % 255) / 255.0
        let blue = Double(arc4random() % 255) / 255.0
        let alpha = 1.0
        return Color.init(red: red, blue: blue, green: green, alpha: alpha)
    }
    
    
    // 每次绘制均执行的方法，可以再MTKView中的preferredFramesPerSecond指定帧率来控制调用此方法的次数
    func draw(in view: MTKView) {
        let color = makeColor()
        // 1.设置画布颜色, 可以理解成OpenGLES 中的glClearColor
        view.clearColor = MTLClearColorMake(color.red, color.green, color.blue, 1.0)
        
        // 2. 使用命令队列开辟一个命令缓冲区，用于存储当前渲染缓冲区中的每个指令，发送给GPU执行
        let commandBuffer = commandQueue.makeCommandBuffer()
        commandBuffer?.label = "myCommandBuffer"
        
        // 3. 从MTKView中获取渲染描述符
        guard let renderPassDescriptor = view.currentRenderPassDescriptor else {
            print("当前渲染描述符为空，无法执行下一步绘制操作")
            return
        }
        
        // 4. 通过命令缓冲区使用渲染描述符来创建MTKComputerCommandEncoder对象
        let commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: renderPassDescriptor)
        commandEncoder?.label = "myCommandEncoder"
        
        
        // .... 如果有绘制命令写在这里即可，本案只是简单熟悉一下Metal配置流程
        
        // 5. 结束命令编辑
        commandEncoder?.endEncoding()
        
        // 因为GPU是不会直接渲染在视图上，需要你发送present和commit命令才能渲染在指定视图上
        
        guard let currentDrawable = view.currentDrawable else {
            print("获取当前帧失败")
            return
        }
        commandBuffer?.present(currentDrawable)
        commandBuffer?.commit()
        
    }
    
    // 每当窗口变化或重新布局（设备方向改变时）均调用此方法
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
}
