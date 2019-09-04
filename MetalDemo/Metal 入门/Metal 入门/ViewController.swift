//
//  ViewController.swift
//  Metal 入门
//
//  Created by 欧阳林 on 2019/7/6.
//  Copyright © 2019年 欧阳林. All rights reserved.
//

import UIKit
import MetalKit

class ViewController: UIViewController {
    
    // 绘制视图，继承与UIView，可以理解成OpenGL ES 中的绘制表面
    private var mtkView: MTKView = MTKView()
    
    private var render: OMRender!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //1. 创建MTKView
        mtkView.device = MTLCreateSystemDefaultDevice()
        mtkView.frame = view.frame
        // 每秒钟绘制的帧数
        mtkView.preferredFramesPerSecond = 2
        self.view.addSubview(mtkView)
        
        // 创建一个渲染循环
        self.render = OMRender.init(mtkView: mtkView)
        // 将渲染回调代理只想渲染循环
        mtkView.delegate = self.render

    }


}

