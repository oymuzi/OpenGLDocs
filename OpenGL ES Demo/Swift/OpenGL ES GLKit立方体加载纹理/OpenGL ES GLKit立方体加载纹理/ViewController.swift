//
//  ViewController.swift
//  OpenGL ES GLKit立方体加载纹理
//
//  Created by ios on 2019/6/6.
//  Copyright © 2019 oymuzi. All rights reserved.
//

import UIKit
import GLKit


struct VertexBuffer {
    var x: GLfloat
    var y: GLfloat
    var z: GLfloat
    var textureCoordx: GLfloat
    var trxtureCoordy: GLfloat
}

class ViewController: UIViewController {
    
    private let baseEffect = GLKBaseEffect()
    
    private var glkView: GLKView!
    
    private var angle = 0
    
    private var vertexsBufferID: GLuint = 0
    
    private var indexBufferID: GLuint = 0
    
    private var indexs = [GLfloat]()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupConfigure()
        self.prepareSource()
        self.setupTexture()
        self.addDisplayLink()
    }
    
    private func setupConfigure(){
        guard let context = EAGLContext.init(api: .openGLES3) else {
            print("初始化上下文失败")
            return
        }
        EAGLContext.setCurrent(context)
        
        let glkView = GLKView.init(frame: CGRect.init(x: 0, y: 100, width: self.view.frame.width, height: self.view.frame.width), context: context)
        glkView.delegate = self
        glkView.drawableColorFormat = .RGBA8888;
        glkView.drawableDepthFormat = .format24;
        glkView.drawableMultisample = .multisample4X;
        glkView.drawableStencilFormat = .format8;
        self.view.addSubview(glkView)
        self.glkView = glkView
        
        glClearColor(0.3, 0.3, 0.3, 1.0)
    }
    
    
    private func prepareSource(){
        
        let vertexs: Array<VertexBuffer> = [
        
            // 正面
            VertexBuffer.init(x: 0.5, y: -0.5, z: 0.5, textureCoordx: 1, trxtureCoordy: 0),
            VertexBuffer.init(x: 0.5, y: 0.5, z: 0.5, textureCoordx: 1, trxtureCoordy: 1),
            VertexBuffer.init(x: -0.5, y: 0.5, z: 0.5, textureCoordx: 0, trxtureCoordy: 1),
            VertexBuffer.init(x: 0.5, y: -0.5, z: 0.5, textureCoordx: 1, trxtureCoordy: 0),
            VertexBuffer.init(x: -0.5, y: 0.5, z: 0.5, textureCoordx: 0, trxtureCoordy: 1),
            VertexBuffer.init(x: -0.5, y: -0.5, z: 0.5, textureCoordx: 0, trxtureCoordy: 0),
            
            
            // 后面
            VertexBuffer.init(x: -0.5, y: -0.5, z: -0.5, textureCoordx: 1, trxtureCoordy: 0),
            VertexBuffer.init(x: -0.5, y: 0.5, z: -0.5, textureCoordx: 1, trxtureCoordy: 1),
            VertexBuffer.init(x: 0.5, y: 0.5, z: -0.5, textureCoordx: 0, trxtureCoordy: 1),
            VertexBuffer.init(x: -0.5, y: -0.5, z: -0.5, textureCoordx: 1, trxtureCoordy: 0),
            VertexBuffer.init(x: 0.5, y: 0.5, z: -0.5, textureCoordx: 0, trxtureCoordy: 1),
            VertexBuffer.init(x: 0.5, y: -0.5, z: -0.5, textureCoordx: 0, trxtureCoordy: 0),
            
            
            // 左面
            VertexBuffer.init(x: -0.5, y: -0.5, z: 0.5, textureCoordx: 1, trxtureCoordy: 0),
            VertexBuffer.init(x: -0.5, y: 0.5, z: 0.5, textureCoordx: 1, trxtureCoordy: 1),
            VertexBuffer.init(x: -0.5, y: 0.5, z: -0.5, textureCoordx: 0, trxtureCoordy: 1),
            VertexBuffer.init(x: -0.5, y: -0.5, z: 0.5, textureCoordx: 1, trxtureCoordy: 0),
            VertexBuffer.init(x: -0.5, y: 0.5, z: -0.5, textureCoordx: 0, trxtureCoordy: 1),
            VertexBuffer.init(x: -0.5, y: -0.5, z: -0.5, textureCoordx: 0, trxtureCoordy: 0),
            
            // 右面
            VertexBuffer.init(x: 0.5, y: -0.5, z: -0.5, textureCoordx: 1, trxtureCoordy: 0),
            VertexBuffer.init(x: 0.5, y: 0.5, z: -0.5, textureCoordx: 1, trxtureCoordy: 1),
            VertexBuffer.init(x: 0.5, y: 0.5, z: 0.5, textureCoordx: 0, trxtureCoordy: 1),
            VertexBuffer.init(x: 0.5, y: -0.5, z: -0.5, textureCoordx: 1, trxtureCoordy: 0),
            VertexBuffer.init(x: 0.5, y: 0.5, z: 0.5, textureCoordx: 0, trxtureCoordy: 1),
            VertexBuffer.init(x: 0.5, y: -0.5, z: 0.5, textureCoordx: 0, trxtureCoordy: 0),

            
            // 上面
            VertexBuffer.init(x: 0.5, y: 0.5, z: 0.5, textureCoordx: 1, trxtureCoordy: 0),
            VertexBuffer.init(x: 0.5, y: 0.5, z: -0.5, textureCoordx: 1, trxtureCoordy: 1),
            VertexBuffer.init(x: -0.5, y: 0.5, z: -0.5, textureCoordx: 0, trxtureCoordy: 1),
            VertexBuffer.init(x: 0.5, y: 0.5, z: 0.5, textureCoordx: 1, trxtureCoordy: 0),
            VertexBuffer.init(x: -0.5, y: 0.5, z: -0.5, textureCoordx: 0, trxtureCoordy: 1),
            VertexBuffer.init(x: -0.5, y: 0.5, z: 0.5, textureCoordx: 0, trxtureCoordy: 0),
            
            
            // 下面
            VertexBuffer.init(x: 0.5, y: -0.5, z: 0.5, textureCoordx: 1, trxtureCoordy: 0),
            VertexBuffer.init(x: 0.5, y: -0.5, z: -0.5, textureCoordx: 1, trxtureCoordy: 1),
            VertexBuffer.init(x: -0.5, y: -0.5, z: -0.5, textureCoordx: 0, trxtureCoordy: 1),
            VertexBuffer.init(x: 0.5, y: -0.5, z: 0.5, textureCoordx: 1, trxtureCoordy: 0),
            VertexBuffer.init(x: -0.5, y: -0.5, z: -0.5, textureCoordx: 0, trxtureCoordy: 1),
            VertexBuffer.init(x: -0.5, y: -0.5, z: 0.5, textureCoordx: 0, trxtureCoordy: 0),
        ]
        
        
        let indices: Array<GLfloat> = [
            // 前面
            0, 1, 2, 0, 2, 3,
            // 后面
            4, 5, 6, 4, 6, 7,
            // 左面
            8, 9, 10, 8, 10, 11,
            // 右面
            12, 13, 14, 12, 14, 15,
            // 上面
            16, 17, 18, 16, 18, 19,
            // 下面
            20, 21, 22, 20, 21, 23
        ]
        self.indexs = indices
        
//        glGenVertexArraysOES(1, &vertexs)
//        glBindVertexArrayOES()
        
        glGenBuffers(1, &vertexsBufferID)
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertexsBufferID)
        glBufferData(GLenum(GL_ARRAY_BUFFER), MemoryLayout<VertexBuffer>.size * vertexs.count, vertexs, GLenum(GL_STATIC_DRAW))
        
        glGenBuffers(1, &indexBufferID)
        glBindBuffer(GLenum(GL_ELEMENT_ARRAY_BUFFER), indexBufferID)
        glBufferData(GLenum(GL_ELEMENT_ARRAY_BUFFER), MemoryLayout<GLfloat>.size * indices.count, indices, GLenum(GL_STATIC_DRAW))
        
        
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.position.rawValue))
        let positionPtr = UnsafeRawPointer.init(bitPattern: MemoryLayout<GLfloat>.size * 0)
        glVertexAttribPointer(GLuint(GLKVertexAttrib.position.rawValue), 3, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<VertexBuffer>.size), positionPtr)
        
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.texCoord0.rawValue))
        let texturePtr = UnsafeRawPointer.init(bitPattern: MemoryLayout<GLfloat>.size * 3)
        glVertexAttribPointer(GLuint(GLKVertexAttrib.texCoord0.rawValue), 2, GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<VertexBuffer>.size), texturePtr)
        
        glActiveTexture(GLenum(GL_TEXTURE0))
    }
    
    private func setupTexture(){
        var paths = [String]()
        guard let path = Bundle.main.resourcePath else {
            return;
        }
        paths.append(path + "/1.png")
        paths.append(path + "/2.png")
        paths.append(path + "/3.png")
        paths.append(path + "/4.png")
        paths.append(path + "/5.png")
        paths.append(path + "/6.png")
        
        let cubePath = path + "/cube.png"
        let options = [GLKTextureLoaderOriginBottomLeft: NSNumber.init(value: 1)];
        do{
            let textureInfo: GLKTextureInfo = try GLKTextureLoader.texture(withContentsOfFile: cubePath, options: options)//try GLKTextureLoader.cubeMap(withContentsOfFiles: paths, options: options)
            print("加载的纹理：\(textureInfo)")
//            glBindTexture(GLenum(GL_TEXTURE_CUBE_MAP), textureInfo.target)
            self.baseEffect.texture2d0.name = textureInfo.name
            self.baseEffect.texture2d0.target = GLKTextureTarget(rawValue: textureInfo.target)!
            self.baseEffect.texture2d0.enabled = 1
        } catch{
            print("加载纹理出错: \(error.localizedDescription)")
        }
        
    }
    
    
    private func addDisplayLink(){
        let displaylink = CADisplayLink.init(target: self, selector: #selector(update))
        displaylink.add(to: .main, forMode: .common)
    }
    
    @objc private func update(){
        self.angle = (self.angle + 2) % 360
        
        self.baseEffect.transform.modelviewMatrix = GLKMatrix4MakeRotation(GLKMathDegreesToRadians(Float(self.angle)), 0.5, 1.0, 0.0)
        self.glkView.setNeedsDisplay()
    }

}


extension ViewController: GLKViewDelegate{
    
    func glkView(_ view: GLKView, drawIn rect: CGRect) {
        glEnable(GLenum(GL_DEPTH_TEST))
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT))
        self.baseEffect.prepareToDraw()
        glDrawArrays(GLenum(GL_TRIANGLES), 0, 36)
        
//        let size = MemoryLayout.size(ofValue: indexs) / MemoryLayout<GLfloat>.size
//        var ind = 0
//        glDrawElements(GLenum(GL_TRIANGLES), GLsizei(size), GLenum(GL_UNSIGNED_BYTE), &ind)
    }
    
}

