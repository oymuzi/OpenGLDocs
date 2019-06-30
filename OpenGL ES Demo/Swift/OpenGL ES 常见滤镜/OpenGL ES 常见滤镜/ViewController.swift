//
//  ViewController.swift
//  OpenGL ES 常见滤镜
//
//  Created by 欧阳林 on 2019/6/29.
//  Copyright © 2019年 欧阳林. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.init(white: 0.9, alpha: 1.0)
        
        let drawView = OMView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.width))
        drawView.center = self.view.center
        self.view.addSubview(drawView)
        
        
        let filterView = OMFilterView.init(frame: CGRect.init(x: 0, y: 0, width: self.view.frame.width, height: 80))
        filterView.center = CGPoint(x: self.view.frame.width / 2 , y: self.view.frame.maxY - 70.0)
        
        filterView.setTitleArray(titles: ["普通", "灰度", "翻转", "旋涡", "马赛克", "蜂窝马赛克"])
        filterView.selectedTitleBlock = { [weak self] index  in
            guard let _ = self else { return }
            switch index {
            case 0:
                drawView.changeProgramWithName("Normal")
            case 1:
                drawView.changeProgramWithName("BlackWhite")
            case 2:
                drawView.changeProgramWithName("Reverse")
            case 3:
                drawView.changeProgramWithName("Votex")
            case 4:
                drawView.changeProgramWithName("Mosaic")
            case 5:
                drawView.changeProgramWithName("Mosaic2")
            default:
                break
            }
        }
        self.view.addSubview(filterView)
        
    }


}

