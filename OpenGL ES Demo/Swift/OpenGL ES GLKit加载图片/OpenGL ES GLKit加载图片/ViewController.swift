//
//  ViewController.swift
//  OpenGL ES GLKit加载图片
//
//  Created by ios on 2019/6/5.
//  Copyright © 2019 oymuzi. All rights reserved.
//

import UIKit
import GLKit
import OpenGLES

struct VertexBuffer {
    var x: GLfloat
    var y: GLfloat
    var z: GLfloat
    var texturex: GLfloat
    var texturey: GLfloat
}

class ViewController: UIViewController {
    
    private var glKitView: GLKView!
    // 渲染器
    private var glEffect: GLKBaseEffect = GLKBaseEffect.init()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 开始准备工作
        self.setupConfigure()
        
        // 设置顶点、拷贝数据到缓冲区
        self.setupVertexData()
        
        // 加载纹理
        self.setupTexture()
        
    }
    
    private func setupConfigure(){
        // 初始化上下文
        guard let context = EAGLContext.init(api: .openGLES3) else {
            print("初始化失败")
            return
        }
        EAGLContext.setCurrent(context)
        // 初始化GLKView
        glKitView = GLKView.init(frame: CGRect.init(x: 0, y: 200, width: self.view.frame.width, height: self.view.frame.width))
        glKitView.delegate = self
        glKitView.context = context
        // 设置颜色缓冲区格式
        glKitView.drawableColorFormat = .RGBA8888
        // 设置深度缓冲区格式
        glKitView.drawableDepthFormat = .format24
        // 设置多重采用格式
        glKitView.drawableMultisample = .multisample4X
        // 设置模板缓冲区格式
        glKitView.drawableStencilFormat = .format8
        self.view.addSubview(glKitView)
        // 清屏颜色
        glClearColor(0.3, 0.3, 0.3, 1)
    }
    
    private func setupVertexData(){
        
        /** 1.设置顶点数据、纹理坐标数据，由于纹理坐标左下是[0, 0], 右上才是[1, 1]*/
        let vertexData: Array = [
            VertexBuffer.init(x: 1, y: -1, z: 0, texturex: 1.0, texturey: 0.0),
            VertexBuffer.init(x: 1, y: 1, z: 0, texturex: 1.0, texturey: 1.0),
            VertexBuffer.init(x: -1, y: 1, z: 0, texturex: 0.0, texturey: 1.0),
            
            VertexBuffer.init(x: 1, y: -1, z: 0, texturex: 1.0, texturey: 0.0),
            VertexBuffer.init(x: -1, y: 1, z: 0, texturex: 0.0, texturey: 1.0),
            VertexBuffer.init(x: -1, y: -1, z: 0, texturex: 0.0, texturey: 0.0)
            
        ]
        // 2.开辟顶点缓冲区
        var bufferID: GLuint = 0
        glGenBuffers(1, &bufferID);
        // 3.绑定顶点缓冲区
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), bufferID);
        // 4.讲顶点数据、纹理数据复制到顶点缓冲区
        glBufferData(GLenum(GL_ARRAY_BUFFER), GLsizeiptr(MemoryLayout<VertexBuffer>.size * vertexData.count), vertexData, GLenum(GL_STATIC_DRAW));
        // 5.开启顶点attribute通道并传递顶点坐标数据
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.position.rawValue))
        /**
         参数一：每次读取的顶点个数，顶点是(x, y, z)组成，所以是3个
         参数二：数组内每个数据的类型
         参数三：步长，读取一次顶点后偏移步长后开始读取下一顶点，读取完一次数据是五个，所以偏移是5
         参数四：
         */
        let pointerPtr = UnsafeRawPointer.init(bitPattern: MemoryLayout<GLfloat>.size * 0)
        glVertexAttribPointer(GLuint(GLKVertexAttrib.position.rawValue), 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<VertexBuffer>.size), pointerPtr)
        //6.开启纹理通道并传输纹理坐标数据
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.texCoord0.rawValue))
        let texturePtr = UnsafeRawPointer.init(bitPattern: MemoryLayout<GLfloat>.size * 3)
        glVertexAttribPointer(GLuint(GLKVertexAttrib.texCoord0.rawValue), 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<VertexBuffer>.size), texturePtr)
        
    }
    
    // 加载纹理
    private func setupTexture(){
        let texturePath = Bundle.main.path(forResource: "shell", ofType: "jpg") ?? ""
        print("纹理路径：\(texturePath)")
        do {
            let options = [GLKTextureLoaderOriginBottomLeft: NSNumber.init(value: 1)];
            let textureInfo = try GLKTextureLoader.texture(withContentsOfFile: texturePath, options: options)
            self.glEffect.texture2d0.enabled = 1
            self.glEffect.texture2d0.name = textureInfo.name
            self.glEffect.texture2d0.target = GLKTextureTarget(rawValue: textureInfo.target)!
            
        } catch {
            print("出现错误：\(error.localizedDescription)")
        }
    }
    
}

extension ViewController: GLKViewDelegate{
    
    func glkView(_ view: GLKView, drawIn rect: CGRect) {
        
        // 清除颜色缓冲区
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        // 准备开始绘制
        glEffect.prepareToDraw()
        
        // 开始绘制
        /**
         参数一：绘制的类型
         参数二：从那个点开始绘制
         参数三：总共有几个点
         */
        glDrawArrays(GLenum(GL_TRIANGLES), 0, 6);
    }
}
