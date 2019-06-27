//
//  ViewController.swift
//  OpenGL ES 滤镜入门
//
//  Created by 欧阳林 on 2019/6/26.
//  Copyright © 2019年 欧阳林. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let drawView = OMView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.width))
        drawView.center = self.view.center
        self.view.addSubview(drawView)
        
    }


}

