//
//  ViewController.m
//  Metal 实时预览相机
//
//  Created by 欧阳林 on 2019/7/14.
//  Copyright © 2019年 欧阳林. All rights reserved.
//

@import MetalKit;
@import GLKit;
@import CoreMedia;
@import AVFoundation;



#import "ViewController.h"
#import <MetalPerformanceShaders/MetalPerformanceShaders.h>

@interface ViewController ()<MTKViewDelegate, AVCaptureAudioDataOutputSampleBufferDelegate>

/** 渲染视图*/
@property (strong, nonatomic) MTKView *mtkView;
/** 负责输入设备和输出设备传递*/
@property (strong, nonatomic) AVCaptureSession *mCaptureSession;
/** 输入设备*/
@property (strong, nonatomic) AVCaptureInput *mCaptureInput;
/** 输出设备*/
@property (strong, nonatomic) AVCaptureVideoDataOutput *mCaptureOutput;
/** 处理队列*/
@property (strong, nonatomic) dispatch_queue_t processQueue;
/** 纹理缓存区*/
@property (assign, nonatomic) CVMetalTextureCacheRef textureCache;
/** 命令队列*/
@property (strong, nonatomic) id<MTLCommandQueue> commandQueue;
/** 纹理*/
@property (strong, nonatomic) id<MTLTexture> texture;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupMetal];
    [self setupCaptureSession];
}

- (void)setupMetal{
    // 1. 设置渲染视图视图
    self.mtkView = [[MTKView alloc] initWithFrame:self.view.frame device:MTLCreateSystemDefaultDevice()];
    self.mtkView.delegate = self;
    [self.view addSubview:self.mtkView];
    // MTKView的drawable纹理默认是只读的，我们需要设置为可读写
    self.mtkView.framebufferOnly = NO;
    // 还得创建纹理缓冲区
    CVMetalTextureCacheCreate(NULL, NULL, self.mtkView.device, NULL, &_textureCache);
    
    // 2. 创建命令缓冲区
    self.commandQueue = [self.mtkView.device newCommandQueue];
    
}

- (void)setupCaptureSession{
    // 1.创建捕捉会话
    self.mCaptureSession = [[AVCaptureSession alloc] init];
    // 2. 设置视频采集的分辨率
    [self.mCaptureSession setSessionPreset:AVCaptureSessionPresetHigh];
    // 3. 创建串行队列
    self.processQueue = dispatch_queue_create("processQueue", DISPATCH_QUEUE_SERIAL);
    // 4.获取摄像头设备，找到后置摄像头
    NSArray *devices;
    if(@available(iOS 10.0, *)){
        AVCaptureDeviceDiscoverySession *session = [AVCaptureDeviceDiscoverySession discoverySessionWithDeviceTypes:@[AVCaptureDeviceTypeBuiltInWideAngleCamera] mediaType:AVMediaTypeVideo position:AVCaptureDevicePositionBack];
        devices = session.devices;
    } else {
        devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    }
    AVCaptureDevice *inputDevice = nil;
    for (AVCaptureDevice *device in devices){
        if (device.position == AVCaptureDevicePositionBack){
            inputDevice = device;
        }
    }
    
    
    //5. 将AVCaptureDevice转换为AVCaptureDeviceInput
    self.mCaptureInput = [[AVCaptureDeviceInput alloc] initWithDevice:inputDevice error:nil];
    if ([self.mCaptureSession canAddInput:self.mCaptureInput]){
        [self.mCaptureSession addInput:self.mCaptureInput];
    }
    
    //6. 创建AVCaptureVideoDataOutput对象
    self.mCaptureOutput = [[AVCaptureVideoDataOutput alloc] init];
    
    // 7. 设置视频帧延迟时是否丢弃
    [self.mCaptureOutput setAlwaysDiscardsLateVideoFrames:NO];
    
    // 8.设置格式为BGRA，不设置YUV是避免Shader转换
    [self.mCaptureOutput setVideoSettings:@{(id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA)}];
    
    // 9. 设置视频捕捉输出的代理和队列
    [self.mCaptureOutput setSampleBufferDelegate:self queue:self.processQueue];
    
    // 10. 添加输出
    if ([self.mCaptureSession canAddOutput:self.mCaptureOutput]){
        [self.mCaptureSession addOutput:self.mCaptureOutput];
    }
    
    // 11. 输入与输出链接, 并且需要设置视频方向，否则会造成图像异常
    AVCaptureConnection *connection = [self.mCaptureOutput connectionWithMediaType:AVMediaTypeVideo];
    [connection setVideoOrientation:AVCaptureVideoOrientationPortrait];

    //12. 开始捕捉
    [self.mCaptureSession startRunning];
    
}


#pragma 视频捕捉代理
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection{
    
    //1. 从sampleBuffer 中获取像素缓冲区对象
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    
    // 2.获取视频的宽高
    size_t width = CVPixelBufferGetWidth(pixelBuffer);
    size_t height = CVPixelBufferGetHeight(pixelBuffer);
    
    // 3.从现有图像缓冲区创建k核心视频Metal纹理缓冲区
    /**
     参数1： allocator 内存分配器
     参数2: textureCache 纹理缓存对象
     参数3：sourceImage 图像缓冲区
     参数4: textureAttributes 纹理参数字典
     参数5: pixelFormat 图像缓存区数据的像素格式，如果设置的格式和c视频采集的格式不同会造成图像异常
     参数6: width 纹理图像宽（像素）
     参数7: height 纹理图像高(像素)
     参数8: planeIndex。 如果图像缓冲区是平面的，则为映射纹理数据的索引值
     参数9：textureOut 返回创建的纹理缓冲区
     */
    CVMetalTextureRef tempTexture = NULL;
    CVReturn status = CVMetalTextureCacheCreateTextureFromImage(kCFAllocatorDefault,  self.textureCache, pixelBuffer, NULL, MTLPixelFormatBGRA8Unorm, width, height, 0, &tempTexture);
    if (status == kCVReturnSuccess){
        //4 .设置可绘制纹理的当前大小
        self.mtkView.drawableSize = CGSizeMake(width, height);
        // 5.获取纹理缓冲区的Metal纹理对象
        self.texture = CVMetalTextureGetTexture(tempTexture);
        CFRelease(tempTexture);
    }
}


#pragma MTKViewDelegate

- (void)drawInMTKView:(MTKView *)view{
    // 1. 判断是否获取了摄像头采集的纹理数据
    if(self.texture){
        //2. 创建命令缓冲区
        id<MTLCommandBuffer> commandBuffer = [self.commandQueue commandBuffer];
        //3. 将MTKView作为目标渲染纹理
        id<MTLTexture> texture = view.currentDrawable.texture;
        
        //4. 设置滤镜，MetalPerformanceShader是Metal的一个集成库，有一些Metal滤镜实现
        MPSImageGaussianBlur *filter = [[MPSImageGaussianBlur alloc] initWithDevice:view.device sigma: 5];
        /* 5. 以一个纹理的输出作为另一个纹理的输入
         输入：摄像头采集的图像纹理
         输出：创建的纹理texture（就是view.currentDrawable.texture）
         */
        [filter encodeToCommandBuffer:commandBuffer sourceTexture:self.texture destinationTexture:texture];
        
        // 6. 展示内容
        [commandBuffer presentDrawable:view.currentDrawable];
        // 7. 提交命令
        [commandBuffer commit];
        // 8. 清空当前纹理，准备下一帧纹理
        self.texture = NULL;
    }
    
}

- (void)mtkView:(MTKView *)view drawableSizeWillChange:(CGSize)size{
    
}


@end
