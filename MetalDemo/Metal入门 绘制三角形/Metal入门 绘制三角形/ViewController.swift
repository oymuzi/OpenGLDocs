//
//  ViewController.swift
//  Metal入门 绘制三角形
//
//  Created by 欧阳林 on 2019/7/6.
//  Copyright © 2019年 欧阳林. All rights reserved.
//

import UIKit
import MetalKit

class ViewController: UIViewController {
    
    private var mtkView: MTKView = MTKView()
    private var render: OMRender!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        mtkView.frame = view.frame
        mtkView.device = MTLCreateSystemDefaultDevice()
        view.addSubview(mtkView)
        
        render = OMRender.init(mtkView: mtkView)
        mtkView.delegate = render
    }


}

