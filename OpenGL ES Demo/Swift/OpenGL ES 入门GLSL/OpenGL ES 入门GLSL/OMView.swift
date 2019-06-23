//
//  OMView.swift
//  OpenGL ES 入门GLSL
//
//  Created by ios on 2019/6/21.
//  Copyright © 2019 欧阳林. All rights reserved.
//

import UIKit
import OpenGLES
import CoreImage


struct OMVertex {
    var x: GLfloat
    var y: GLfloat
    var z: GLfloat
    var textureX: GLfloat
    var textureY: GLfloat
}

class OMView: UIView {

    private var myEaglLayer: CAEAGLLayer!
    
    private var myContext: EAGLContext!
    
    private var myColorRenderBuffer: GLuint = 0
    
    private var myColorFrameBuffer: GLuint = 0
    
    private var myProgram: GLuint = 0


    
    private func setupUI(){
        
        self.setupLayer()
        self.setupContext()
        self.clearAllBuffers()
        self.setupRenderBuffer()
        self.setupFrameBuffer()
        self.renderLayer()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.setupUI()
    }
    
    override class var layerClass: AnyClass{
        return CAEAGLLayer.self
    }
    
    // 1.设置图层
    private func setupLayer(){
        self.myEaglLayer = self.layer as? CAEAGLLayer
        // 设置放大缩放系数
        self.contentScaleFactor = UIScreen.main.scale
        // kEAGLDrawablePropertyRetainedBacking 表示绘制表面后是否还保留其内容
        
        // kEAGLDrawablePropertyColorFormat 表示绘制表面颜色格式
        // kEAGLColorFormatRGBA8    32位RGBA颜色，R、G、B、A分别占八位
        // kEAGLColorFormatRGB565   16位RGB颜色，R-5位 G-6位 B-5位
        // kEAGLColorFormatSRGBA8   sRGB格式代表了标准的红、绿、蓝以及透明度，sRGB基于独立的色彩空间，不会受不同设备的不同的色彩坐标影响，可以使不同的设备使用传输中对应同一个色彩坐标系。广泛应用在CRT显示器，LCD显示器、投影仪、打印机以及其他一些再现使用的三个基本色素
        let properties: [String :Any] = [kEAGLDrawablePropertyRetainedBacking: false,
                              kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8
        ]
        self.myEaglLayer.drawableProperties = properties
    }
    
    // 2.设置上下文
    private func setupContext(){
        // 创建上下文
        guard let context = EAGLContext.init(api: .openGLES3) else {
            print("创建上下文失败")
            return
        }
        // 设置图形上下文
        guard EAGLContext.setCurrent(context) else {
            print("设置上下文失败")
            return
        }
       // 设置全局图形上下文
        self.myContext = context
    }
    
    // 3.清空缓存区
    private func clearAllBuffers(){
        /* buffer分为frame buffer（FBO） 和 render buffer（RBO）
         * frame buffer 是render buffer 的管理类
         * render buffer分为三类 color buffer、depth buffer、stencil buffer
         */
        
        glDeleteBuffers(1, &myColorFrameBuffer)
        glDeleteBuffers(1, &myColorRenderBuffer)
        
        self.myColorFrameBuffer = 0
        self.myColorRenderBuffer = 0
    }
    
    // 4.设置渲染缓存区
    private func setupRenderBuffer(){
        // 1.申明一个buffer
        var buffer: GLuint = 0
        // 2.申请一个缓存区标志
        glGenRenderbuffers(1, &buffer)
        // 3. 设置全局buffer
        self.myColorRenderBuffer = buffer
        // 4. 将标识符绑定到渲染缓存区
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), self.myColorRenderBuffer)
        // 5. 将EAGLLayer上的可绘制对象存储绑定到Render Buffer对象上
        self.myContext.renderbufferStorage(Int(GL_RENDERBUFFER), from: self.myEaglLayer)
    }
    
    // 5.设置帧缓存区
    private func setupFrameBuffer(){
        // 1. 申明一个buffer
        var buffer: GLuint = 0
        // 2. 申请一个Frame Buffer标志
        glGenFramebuffers(1, &buffer)
        // 3. 设置全局Frame buffer
        self.myColorFrameBuffer = buffer
        // 4. 将标识符绑定到Frame Buffer
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), self.myColorFrameBuffer)
        // 5. 生成帧缓存区之后需要将frame buffer 和 render buffer进行绑定
        glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_RENDERBUFFER), self.myColorRenderBuffer)
    }
    
    // 6. 开始绘制
    private func renderLayer(){
        // 1. 设置清屏颜色
        glClearColor(1.0, 1.0, 1.0, 1.0)
        // 2. 清除屏幕
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        // 3. 设置视口大小
        let scale = UIScreen.main.scale
        glViewport(GLint(self.frame.origin.x * scale), GLint(self.frame.origin.y * scale), GLsizei(self.frame.width * scale), GLsizei(self.frame.height * scale))
        
        // 4.读取顶点着色器和片元着色器文件
        guard let vertexShaderFilePath = Bundle.main.path(forResource: "shaderv", ofType: "vsh") else {
            print("加载顶点着色器出错")
            return
        }
        guard let fragmentShaderFilePath = Bundle.main.path(forResource: "shaderf", ofType: "fsh") else {
            print("加载片元着色器出错")
            return
        }
        
        // 5.加载着色器
        var vertexShader: GLuint = 0
        var fragmentShader: GLuint = 0
        self.loadShaderAndCompilerWith(shader: &vertexShader, path: vertexShaderFilePath, shaderType: GLenum(GL_VERTEX_SHADER))
        self.loadShaderAndCompilerWith(shader: &fragmentShader, path: fragmentShaderFilePath, shaderType: GLenum(GL_FRAGMENT_SHADER))
        
        // 6. 创建一个程序
        let program = glCreateProgram()
        
        // 7. 将着色器附着在程序上
        glAttachShader(program, vertexShader)
        glAttachShader(program, fragmentShader)
        
        self.myProgram = program
        // 8. 已经附着在程序上可删除着色器
        glDeleteShader(vertexShader)
        glDeleteShader(fragmentShader)
        
        // 9.链接程序并检查是否有问题
        glLinkProgram(program)
        
        var linkStatus: GLint = 0
        glGetProgramiv(program, GLenum(GL_LINK_STATUS), &linkStatus)
        if linkStatus == GL_FALSE {
            var message: [GLchar] = Array<GLchar>.init(repeating: 0, count: 512)
            glGetProgramInfoLog(program, GLsizei(MemoryLayout.size(ofValue: message)), nil, &message)
            let errorMessage = String.init(cString: message)
            print("链接程序失败，原因：\(errorMessage)")
            return
        }
        
        print("-----😆链接成功-----")
        
        // 10. 使用程序
        glUseProgram(program)
        
        
        // 11. 设置顶点、纹理坐标
        let VAO = [
            OMVertex(x: 1.0, y: -1.0, z: -1.0, textureX: 1, textureY: 0),
            OMVertex(x: 1.0, y: 1.0, z: -1.0, textureX: 1, textureY: 1),
            OMVertex(x: -1.0, y: 1.0, z: -1.0, textureX: 0, textureY: 1),
            
            OMVertex(x: 1.0, y: -1.0, z: -1.0, textureX: 1, textureY: 0),
            OMVertex(x: -1.0, y: 1.0, z: -1.0, textureX: 0, textureY: 1),
            OMVertex(x: -1.0, y: -1.0, z: -1.0, textureX: 0, textureY: 0)
        ]
        
        // 12。处理顶点数据
        //申明一个标识符
        var attributeBuffer: GLuint = 0
        //申请一个缓存区标识符
        glGenBuffers(1, &attributeBuffer)
        //把标识符绑定到GL_ARRAY_BUFFER标识符上
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), attributeBuffer)
        // 把顶点数据拷贝至GPU中
        glBufferData(GLenum(GL_ARRAY_BUFFER), MemoryLayout<OMVertex>.size * VAO.count, VAO, GLenum(GL_STATIC_DRAW))
        
        
        // 13. 将顶点数据通过program传递至顶点着色器中的顶点属性, 且名字必须和顶点着色器的名字一致，并告诉OpenGL ES开启指定的attribute通道
//        let positionName = "position".cString(using: .utf8)
//        let positionNamePtr = UnsafePointer<GLchar>.init(positionName)

        let position = glGetAttribLocation(program, "position")
        glEnableVertexAttribArray(GLuint(position))
        // 设置读取顶点方式
        let positionOffsetPtr = UnsafeRawPointer.init(bitPattern: MemoryLayout<GLfloat>.size * 0)
        glVertexAttribPointer(GLuint(position), 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<OMVertex>.size), positionOffsetPtr)
        
        //14. 处理纹理数据
//        let textureName = "textureCoordinate".cString(using: .utf8)
//        let textureNamePtr = UnsafePointer<GLchar>.init(textureName)
        let texture = glGetAttribLocation(program, "textureCoordinate")
        glEnableVertexAttribArray(GLuint(texture))
        let offsetPtr = UnsafeRawPointer.init(bitPattern: MemoryLayout<GLfloat>.size * 3)
        glVertexAttribPointer(GLuint(texture), 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<OMVertex>.size), offsetPtr)
        
        // 14. 加载纹理
        guard let path = Bundle.main.path(forResource: "timor", ofType: "jpg") else {
            print("获取纹理图片失败")
            return
        }
        self.loadTextureWithImage(path: path)
        
        // 15.设置纹理采样器 sampler2D
//        let colorMapName = "colorMap".cString(using: .utf8)
//        let colorMapNamePtr = UnsafePointer<GLchar>.init(colorMapName)
        glUniform1i(glGetUniformLocation(program, "colorMap"), 0)
        

        // 16.绘制
        glDrawArrays(GLenum(GL_TRIANGLES), 0, 6)
        
        // 17. 把渲染缓存区输出到屏幕上
        self.myContext.presentRenderbuffer(Int(GL_RENDERBUFFER))
        
    }
    
    

    /// 加载着色器并编译返回着色器
    ///
    /// - Parameters:
    ///   - path: 着色器路径
    ///   - shaderType: 着色器类型
    /// - Returns: 着色器
    private func loadShaderAndCompilerWith(shader: inout GLuint, path: String, shaderType: GLenum) {
        var content = ""
        do {
            let contentString = try String.init(contentsOfFile: path)
            content = contentString
        } catch {
            print("加载着色器文件失败")
        }
        
  

        var source: UnsafePointer<GLchar>? = UnsafePointer<GLchar>(content)
        shader = glCreateShader(shaderType)
        glShaderSource(shader, 1, &source, nil)
        glCompileShader(shader)
    }
    
    
    private func loadTextureWithImage(path: String) {
        guard let texture = UIImage.init(contentsOfFile: path) else {
            print("图片地址出错")
            return
        }
        guard let cgImage = texture.cgImage else {
            print("纹理图片转换成位图失败")
            return
        }
        guard let colorSpace = cgImage.colorSpace else {
            print("获取纹理图片的色彩通道失败")
            return
        }
        let imageWidth = cgImage.width
        let imageHeight = cgImage.height
        // 获取图片字节数
        let imageData = calloc(imageWidth * imageHeight * 4, MemoryLayout<GLubyte>.size)
        // 创建上下文
        let context = CGContext.init(data: imageData, width: imageWidth, height: imageHeight, bitsPerComponent: 8, bytesPerRow: imageWidth * 4, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
    
        let rect = CGRect.init(x: 0, y: 0, width: imageWidth, height: imageHeight)
        // 在CGImageRef绘制图片。不同的是Core Graphics的坐标系是在左下角，和纹理坐标是一致的。而UIKit的坐标系的起点是左上角
        context?.draw(cgImage, in: rect)
        // 绘制完释放上下文
//        free(&context)
        // 绑定纹理
        glBindTexture(GLenum(GL_TEXTURE_2D), 0)
        // 设置纹理属性
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GLint(GL_LINEAR))
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GLint(GL_LINEAR))
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GLint(GL_CLAMP_TO_EDGE))
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GLint(GL_CLAMP_TO_EDGE))
        
        // 载入纹理
        let imgW: Float = Float(imageWidth)
        let imgH: Float = Float(imageHeight)
        glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GL_RGBA, GLsizei(imgW), GLsizei(imgH), 0, GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), imageData)
        // 释放数据
        free(imageData)
    }
    
}


extension GLuint {
    var pointer: UnsafeMutablePointer<GLuint> {
        mutating get {
            var pointer: UnsafeMutablePointer<GLuint>!
            withUnsafeMutablePointer(to: &self, { ptr in
                pointer = ptr
            })
            return pointer
        }
    }
}
