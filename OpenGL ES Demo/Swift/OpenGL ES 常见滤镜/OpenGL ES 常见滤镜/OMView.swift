//
//  OMView.swift
//  OpenGL ES 常见滤镜
//
//  Created by 欧阳林 on 2019/6/29.
//  Copyright © 2019年 欧阳林. All rights reserved.
//

import UIKit
import OpenGLES

struct OMVertex {
    var x: GLfloat
    var y: GLfloat
    var z: GLfloat
    var textureX: GLfloat
    var textureY: GLfloat
}

class OMView: UIView {
    
    private var myContext: EAGLContext!
    private var myLayer: CAEAGLLayer!
    private var myProgram: GLuint = 0
    private var myRenderBuffer: GLuint = 0;
    private var myFrameBuffer: GLuint = 0;
    
    private var programName = "Normal"
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let displayLink = CADisplayLink.init(target: self, selector: #selector(update))
        displayLink.add(to: .main, forMode: .common)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    public func changeProgramWithName(_ name: String){
        self.programName = name
        self.layoutSubviews()
    }
    
    @objc private func update(){
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        glUniform1i(glGetUniformLocation(self.myProgram, "sampler"), 0)
        glDrawArrays(GLenum(GL_TRIANGLES), 0, 6)
        self.myContext.presentRenderbuffer(Int(GL_RENDERBUFFER))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.commonInit()
        self.setupProgramWithName(self.programName)
        print("I am called!")
    }
    
    override class var layerClass: AnyClass{
        return CAEAGLLayer.self
    }
    
    private func commonInit(){
        self.myLayer = self.layer as? CAEAGLLayer
        let options: [String: Any] = [kEAGLDrawablePropertyRetainedBacking: false, kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8]
        self.myLayer.drawableProperties = options
        
        
        guard let context = EAGLContext.init(api: .openGLES3) else {
            print("初始化上下文失败")
            return
        }
        guard EAGLContext.setCurrent(context) else {
            print("设置上下文失败")
            return
        }
        self.myContext = context
        
        glDeleteBuffers(1, &self.myRenderBuffer)
        glDeleteBuffers(1, &self.myFrameBuffer)
        self.myRenderBuffer = 0
        self.myFrameBuffer = 0
        
        var renderBuffer:GLuint = 0
        glGenRenderbuffers(1, &renderBuffer)
        glBindRenderbuffer(GLenum(GL_RENDERBUFFER), renderBuffer)
        self.myContext.renderbufferStorage(Int(GL_RENDERBUFFER), from: self.myLayer)
        self.myRenderBuffer = renderBuffer
        
        var frameBuffer: GLuint = 0
        glGenFramebuffers(1, &frameBuffer)
        glBindFramebuffer(GLenum(GL_FRAMEBUFFER), frameBuffer)
        glFramebufferRenderbuffer(GLenum(GL_FRAMEBUFFER), GLenum(GL_COLOR_ATTACHMENT0), GLenum(GL_RENDERBUFFER), self.myRenderBuffer)
        self.myFrameBuffer = frameBuffer
        
        glClearColor(0.3, 0.3, 0.3, 1.0)
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        glViewport(0, 0, GLsizei(self.frame.width), GLsizei(self.frame.height))
        
    }
    
    
    private func setupProgramWithName(_ name: String) {
        guard let vertexFile = Bundle.main.path(forResource: "VertexShader\(name)", ofType: "vsh"), let fragmentFile = Bundle.main.path(forResource: "FragmentShader\(name)", ofType: "fsh") else {
            print("加载着色器失败！")
            return
        }
        
        
        var vertexShader: GLuint = 0
        var fragmentShader: GLuint = 0
        self.compile(shader: &vertexShader, shaderPath: vertexFile, shaderType: GLenum(GL_VERTEX_SHADER))
        self.compile(shader: &fragmentShader, shaderPath: fragmentFile, shaderType: GLenum(GL_FRAGMENT_SHADER))
        
        self.myProgram = glCreateProgram()
        
        glAttachShader(self.myProgram, vertexShader)
        glAttachShader(self.myProgram, fragmentShader)
        
        glDeleteShader(vertexShader)
        glDeleteShader(fragmentShader)
        
        glLinkProgram(self.myProgram)
        var status: GLint = 0
        glGetProgramiv(self.myProgram, GLenum(GL_LINK_STATUS), &status)
        if status == GL_FALSE {
            var message = [GLchar]()
            glGetProgramInfoLog(self.myProgram, 512, nil, &message)
            let errorMessage = String.init(cString: message)
            print("⚠️编译程序失败: \(errorMessage)")
            return
        }
        
        print("🍺编译成功")
        
        glUseProgram(self.myProgram)
        
        let vertexArray = [
            OMVertex(x: 1.0, y: -1.0, z: -1.0, textureX: 1.0, textureY: 0.0),
            OMVertex(x: 1.0, y: 1.0, z: -1.0, textureX: 1.0, textureY: 1.0),
            OMVertex(x: -1.0, y: 1.0, z: -1.0, textureX: 0.0, textureY: 1.0),
            
            OMVertex(x: 1.0, y: -1.0, z: -1.0, textureX: 1.0, textureY: 0.0),
            OMVertex(x: -1.0, y: 1.0, z: -1.0, textureX: 0.0, textureY: 1.0),
            OMVertex(x: -1.0, y: -1.0, z: -1.0, textureX: 0.0, textureY: 0.0),
            ]
        var vertexBuffer: GLuint = 0
        glGenBuffers(1, &vertexBuffer)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexBuffer)
        glBufferData(GLenum(GL_ARRAY_BUFFER), MemoryLayout<OMVertex>.size * vertexArray.count, vertexArray, GLenum(GL_DYNAMIC_DRAW))
        
        let position: GLuint = GLuint(glGetAttribLocation(self.myProgram, "position"))
        glEnableVertexAttribArray(position)
        glVertexAttribPointer(position, 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<OMVertex>.size), nil)
        
        let texture: GLuint = GLuint(glGetAttribLocation(self.myProgram, "textureCoordinate"))
        glEnableVertexAttribArray(texture)
        glVertexAttribPointer(texture, 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<OMVertex>.size), UnsafeRawPointer(bitPattern: MemoryLayout<GLfloat>.size * 3))
        
        self.loadTextureWith(name: "cute", type: "jpg")
        
        
    }
    
    private func loadTextureWith(name: String, type: String){
        guard let imagePath = Bundle.main.path(forResource: name, ofType: type) else {
            print("⚠️未能找到名为\(name).\(type)的图片")
            return
        }
        guard let image = UIImage.init(contentsOfFile: imagePath) else {
            print("⚠️加载图片失败")
            return
        }
        guard let cgImage = image.cgImage else {
            print("⚠️获取CGImage失败")
            return
        }
        guard let colorSpace = cgImage.colorSpace else {
            print("⚠️获取图片色彩通道失败")
            return
        }
        
        let imageWidth: size_t = cgImage.width
        let imageHeight: size_t = cgImage.height
        let imageData = calloc(imageWidth * imageHeight * 4, MemoryLayout<GLubyte>.size)
        
        let context = CGContext.init(data: imageData, width: imageWidth, height: imageHeight, bitsPerComponent: 8, bytesPerRow: imageWidth * 4, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        let rect = CGRect.init(x: 0, y: 0, width: imageWidth, height: imageHeight)
        context?.translateBy(x: 0, y: CGFloat(imageHeight))
        context?.scaleBy(x: 1.0, y: -1.0)
        context?.draw(cgImage, in: rect)
        
        glBindTexture(GLenum(GL_TEXTURE_2D), 0)
        
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MIN_FILTER), GL_LINEAR)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_MAG_FILTER), GL_LINEAR)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_S), GL_CLAMP_TO_EDGE)
        glTexParameteri(GLenum(GL_TEXTURE_2D), GLenum(GL_TEXTURE_WRAP_T), GL_CLAMP_TO_EDGE)
        
        let w: Float = Float(imageWidth)
        let h: Float = Float(imageHeight)
        glTexImage2D(GLenum(GL_TEXTURE_2D), 0, GL_RGBA, GLsizei(w), GLsizei(h), 0, GLenum(GL_RGBA), GLenum(GL_UNSIGNED_BYTE), imageData)
        free(imageData)
        
    }
    
    private func compile(shader: inout GLuint, shaderPath: String, shaderType: GLenum){
        guard let content = try? String.init(contentsOfFile: shaderPath).cString(using: .utf8) else {
            print("加载着色器源码失败")
            return
        }
        var shaderSource: UnsafePointer<GLchar>? = UnsafePointer<GLchar>(content)
        shader = glCreateShader(shaderType)
        glShaderSource(shader, 1, &shaderSource, nil)
        glCompileShader(shader)
    }
    
}
