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
        
        let filterView = OMFilterView(frame: CGRect.init(x: 0, y: drawView.frame.maxY+100, width: self.view.frame.width, height: 50))
        let titles = ["普通", "二分屏", "四分屏", "六分屏", "九分屏"]
        filterView.titleArray = titles
        filterView.selectedTitleBlock = { [weak self] index in
            guard let _ = self else { return }
            switch index {
            case 0:
                drawView.changeProgramWithName("Normal")
            case 1:
                drawView.changeProgramWithName("Split2")
            case 2:
                drawView.changeProgramWithName("Split4")
            case 3:
                drawView.changeProgramWithName("Split6")
            case 4:
                drawView.changeProgramWithName("Split9")
            default:
                break
            }
        }
        self.view.addSubview(filterView)
        
    }


}

