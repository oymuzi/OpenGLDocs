//
//  OMFilterView.swift
//  OpenGL ES 常见滤镜
//
//  Created by 欧阳林 on 2019/6/29.
//  Copyright © 2019年 欧阳林. All rights reserved.
//

import UIKit

struct OMFilterModel {
    var title: String
    var isSelected: Bool
}

class OMFilterView: UIView {
    
    private var dataSources = [OMFilterModel]()
    
    public var selectedTitleBlock: ((Int) -> Void)?
    
    private var collectionView: UICollectionView!
    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.setupUI()
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        self.init(coder: aDecoder)
        self.backgroundColor = .clear
        self.setupUI()
    }
    
    private func setupUI(){
        let layout = UICollectionViewFlowLayout.init()
        layout.itemSize = CGSize(width: 85, height: self.frame.height)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        
        self.collectionView = UICollectionView.init(frame: CGRect.init(x: 0, y: 0, width: self.frame.width, height: self.frame.height), collectionViewLayout: layout)
        self.collectionView.backgroundColor = .clear
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.showsVerticalScrollIndicator = false
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.register(OMFilterViewCell.self, forCellWithReuseIdentifier: "cell")
        self.addSubview(self.collectionView)
    }
    
    public func setTitleArray(titles: [String]){
        titles.forEach { (string) in
            self.dataSources.append(OMFilterModel.init(title: string, isSelected: false))
        }
        if !self.dataSources.isEmpty {
            self.dataSources[0].isSelected = true
        }
        self.collectionView.reloadData()
    }
    
    
    
}

extension OMFilterView: UICollectionViewDelegate, UICollectionViewDataSource{
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSources.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! OMFilterViewCell
        let model = self.dataSources[indexPath.item]
        cell.configureCellWith(title: model.title, isSelected: model.isSelected)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        for (index, _) in self.dataSources.enumerated(){
            self.dataSources[index].isSelected = false
        }
        self.dataSources[indexPath.item].isSelected = true
        self.selectedTitleBlock?(indexPath.item)
        collectionView.reloadData()
    }
    
    
}



class OMFilterViewCell: UICollectionViewCell{
    
    private var titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        titleLabel.frame = CGRect.init(x: 0, y: 0, width: 85, height: frame.height)
        titleLabel.textAlignment = .center
        titleLabel.font = UIFont.boldSystemFont(ofSize: 21)
        titleLabel.textColor = UIColor.init(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
        titleLabel.adjustsFontSizeToFitWidth = true
        self.addSubview(titleLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func configureCellWith(title: String, isSelected: Bool){
        titleLabel.text = title
        titleLabel.textColor = isSelected ? UIColor.cyan : UIColor.init(red: 0.6, green: 0.6, blue: 0.6, alpha: 1)
    }
    
    
    
}
