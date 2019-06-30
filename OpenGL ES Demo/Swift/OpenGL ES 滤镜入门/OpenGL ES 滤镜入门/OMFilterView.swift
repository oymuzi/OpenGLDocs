//
//  OMFilterView.swift
//  OpenGL ES 滤镜入门
//
//  Created by 欧阳林 on 2019/6/27.
//  Copyright © 2019年 欧阳林. All rights reserved.
//

import UIKit

class OMFilterView: UIView {

    public var titleArray = [String](){
        didSet{
            self.reloadData()
        }
    }
    
    public var selectedTitleBlock: ((Int) -> Void)?
    
    private var scrollView: UIScrollView!
    
    private var tempButton: UIButton?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupUI()
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init(coder: aDecoder)
        self.setupUI()
    }
    
    private func setupUI(){
        self.scrollView = UIScrollView.init(frame: self.frame)
        self.scrollView.showsVerticalScrollIndicator = false
        self.scrollView.showsHorizontalScrollIndicator = false
        self.addSubview(self.scrollView)
    }
    
    
    
    private func reloadData(){
        guard !self.titleArray.isEmpty else {
            return
        }
        
        let buttonW: CGFloat = 80
        let buttonH: CGFloat = self.frame.size.height
        var contentWidth: CGFloat = 0
        for index in 0..<self.titleArray.count {
            let button = UIButton.init(frame: CGRect.init(x: CGFloat(index)*buttonW, y: 0, width: buttonW, height: buttonH))
            button.setTitle(self.titleArray[index], for: .normal)
            button.setTitleColor(UIColor.init(red: 0.6, green: 0.6, blue: 0.6, alpha: 1), for: .normal)
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 21)
            button.setTitleColor(.cyan, for: .selected)
            button.addTarget(self, action: #selector(selectButton(_:)), for: .touchUpInside)
            button.tag = index
            if index == 0{
                button.isSelected = true
                self.tempButton = button
            }
            self.addSubview(button)
            contentWidth += buttonW
        }
        if contentWidth > self.frame.width{
            self.scrollView.contentSize = CGSize.init(width: contentWidth, height: self.frame.size.height)
        }
    }
    
    @objc private func selectButton(_ button: UIButton){
        if button == self.tempButton {
            return
        }
        button.isSelected = true
        self.tempButton?.isSelected = false
        self.tempButton = button
        self.selectedTitleBlock?(button.tag)
    }
    
    
    
}
