//
//  ViewController.swift
//  Metal 实时相机预览
//
//  Created by 欧阳林 on 2019/7/14.
//  Copyright © 2019年 欧阳林. All rights reserved.
//

import UIKit
import AVFoundation
import MetalKit
import CoreMedia
import MetalPerformanceShaders

class ViewController: UIViewController {
    
    // 渲染视图
    private var mtkView: MTKView!
    // 相机捕捉图像会话
    private var mSession: AVCaptureSession!
    // 输入设备
    private var mCaptureInput: AVCaptureInput!
    // 输出
    private var mCaptureOutput: AVCaptureVideoDataOutput!
    // 处理队列
    private var mProcessQueue: DispatchQueue!
    // 纹理缓冲区
    private var mTextureCache: CVMetalTextureCache!
    // 命令队列
    private var mCommandQueue: MTLCommandQueue!
    // 纹理
    private var mTexture: MTLTexture?
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.setupMetal()
        self.setupCaptureSession()
    }

    
    private func setupMetal(){
        guard let device = MTLCreateSystemDefaultDevice() else {
            print("current device not be supported!")
            return
        }
        mtkView = MTKView.init(frame: self.view.frame, device: device)
        mtkView.delegate = self
        // 默认MTKView的缓冲区是只读的，设置为可读写
        mtkView.framebufferOnly = false
        // 创建纹理缓冲区
        CVMetalTextureCacheCreate(nil, nil, device, nil, &self.mTextureCache)
        self.view.addSubview(mtkView)
        // 创建命令缓冲区
        mCommandQueue = device.makeCommandQueue()

    }
    
    private func setupCaptureSession(){
        // 1.创建捕捉回话session
        mSession = AVCaptureSession()
        // 2.设置分辨率
        mSession.canSetSessionPreset(.high)
        // 3. 创建一个串行队列来处理捕捉的数据
        mProcessQueue = DispatchQueue.init(label: "process queue")
        // 4. 获得后置摄像头
        var tempDevice: AVCaptureDevice?
        if #available(iOS 10.0, *) {
            tempDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: .back)
        } else {
            tempDevice = AVCaptureDevice.devices(for: .video).filter { (device) -> Bool in
                return device.position == .back
            }.first
        }
        guard let device = tempDevice else {
            print("obtain back camera device failured！")
            return
        }
        
        // 6. 把AVCaptureDevice转换成input
        mCaptureInput = try? AVCaptureDeviceInput.init(device: device)
        
        // 7.判断能否加入到会话中
        if mSession.canAddInput(mCaptureInput) {
            mSession.addInput(mCaptureInput)
        }
        
        // 8. 创建输出对象
        mCaptureOutput = AVCaptureVideoDataOutput.init()
        // 设置延迟帧不丢弃
        mCaptureOutput.alwaysDiscardsLateVideoFrames = false
        // 设置格式
        mCaptureOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA];
        // 设置代理
        mCaptureOutput.setSampleBufferDelegate(self, queue: mProcessQueue)
        
        // 9. 添加输出
        if mSession.canAddOutput(mCaptureOutput){
            mSession.addOutput(mCaptureOutput)
        }
        
        // 10.输入与输出链接
        let connection = mCaptureOutput.connection(with: .video)
        // 设置方向，否则可能会出现图像异常
        connection?.videoOrientation = .portrait
        
        // 11. 开始捕捉
        mSession.startRunning()
        
    }

}


// MARK: - MTKViewDelegate
extension ViewController: MTKViewDelegate{
    func draw(in view: MTKView) {
        // 判断是否存在纹理
        guard let texture = mTexture else { return }
        // 创建命令缓冲区
        guard let commandBuffer = mCommandQueue.makeCommandBuffer() else { return }
        commandBuffer.label = "my command buffer"
        // 将MTKView作为目标渲染纹理
        guard let currentDrawable = view.currentDrawable else { return }
        let drawingTexture = currentDrawable.texture
        
        // 设置滤镜, 把相机捕获的内容作为输入到滤镜处理，然后渲染
        let blurFilter = MPSImageGaussianBlur.init(device: view.device!, sigma: 5)
        blurFilter.encode(commandBuffer: commandBuffer, sourceTexture: texture, destinationTexture: drawingTexture)
        
        // 展示纹理到渲染视图上
        commandBuffer.present(currentDrawable)
        // 提交命令
        commandBuffer.commit()
        
        // 清空纹理，准备下一次纹理数据
        mTexture = nil
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
}

//MARK: -AVCaptureVideoDataOutputSampleBufferDelegate
extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate{
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        // 获取像素缓冲区
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        // 获取像素缓冲区的宽高
        let width = CVPixelBufferGetWidth(pixelBuffer)
        let height = CVPixelBufferGetHeight(pixelBuffer)
        
        // 从像素缓冲区创建核心Metal纹理缓冲区
        var tempTextureBuffer: CVMetalTexture?
        /**
         CVMetalTextureCacheCreateTextureFromImage(<#T##allocator: CFAllocator?##CFAllocator?#>, <#T##textureCache: CVMetalTextureCache##CVMetalTextureCache#>, <#T##sourceImage: CVImageBuffer##CVImageBuffer#>, <#T##textureAttributes: CFDictionary?##CFDictionary?#>, <#T##pixelFormat: MTLPixelFormat##MTLPixelFormat#>, <#T##width: Int##Int#>, <#T##height: Int##Int#>, <#T##planeIndex: Int##Int#>, <#T##textureOut: UnsafeMutablePointer<CVMetalTexture?>##UnsafeMutablePointer<CVMetalTexture?>#>)
         allocator:  内存分配器
         textureCache: 纹理缓冲区
         sourceImage: 源数据-图像缓冲区
         textureAttributes: 纹理设置
         pixelFormat： 像素的颜色格式
         width: 宽
         height: 高
         planeIndex: 如果图像缓冲区是平面的，则为映射纹理数据的索引
         textureOut: 输出纹理缓冲区
         
         */
        let status = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault, self.mTextureCache, pixelBuffer, nil, MTLPixelFormat.bgra8Unorm, width, height, 0, &tempTextureBuffer)
        guard status == kCVReturnSuccess else { return }
        
        // 设置渲染视图的绘制纹理大小
        mtkView.drawableSize = CGSize.init(width: CGFloat(width), height: CGFloat(height))
        guard let textureBuffer = tempTextureBuffer else { return }
        // 从纹理缓冲区获取纹理
        mTexture = CVMetalTextureGetTexture(textureBuffer)
        
    }
}
