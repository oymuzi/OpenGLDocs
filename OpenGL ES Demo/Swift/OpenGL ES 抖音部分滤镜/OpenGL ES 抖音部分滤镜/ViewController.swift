//
//  ViewController.swift
//  OpenGL ES 抖音部分滤镜
//
//  Created by oymuzi on 2019/9/4.
//  Copyright © 2019年 oymuzi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    private var startTimeinterval: TimeInterval = 0
    
    private var displayLink: CADisplayLink?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.init(white: 0.9, alpha: 1.0)
        
        let drawView = OMView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.width))
        drawView.center = self.view.center
        self.view.addSubview(drawView)
        
        
        let filterView = OMFilterView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.width, height: 80))
        filterView.center = CGPoint(x: self.view.frame.width / 2 , y: self.view.frame.maxY - 70.0)
        
        filterView.setTitleArray(titles: ["普通", "缩放", "灵魂出窍", "抖动", "闪白", "毛刺"])
        filterView.selectedTitleBlock = { [weak self] index  in
            guard let _ = self else { return }
            switch index {
            case 0:
                drawView.changeProgramWithName("Normal", needTime: false)
            case 1:
                drawView.changeProgramWithName("Scale",  needTime: true)
            case 2:
                drawView.changeProgramWithName("SoulOut",  needTime: true)
            case 3:
                drawView.changeProgramWithName("Shake", needTime: true)
            case 4:
                drawView.changeProgramWithName("ShakeWhite", needTime: true)
            case 5:
                drawView.changeProgramWithName("Glitch", needTime: true)
            default:
                break
            }
        }
        self.view.addSubview(filterView)
        
    }
    
    
    
    
}

