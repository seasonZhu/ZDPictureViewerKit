//
//  ZDPictureViewCell.swift
//  ZDPicViewerDemo
//
//  Created by season on 2018/9/7.
//  Copyright © 2018年 season. All rights reserved.
//

import UIKit
import Kingfisher

/// 这个类可用可不用,因为实际开发中你的cell的结构往往比这个更为复杂
public class ZDPictureViewCell: UICollectionViewCell {
    //MARK:- 属性设置
    
    //  图片
    lazy var imageView: AnimatedImageView = {
        let imageView = AnimatedImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    //MARK:- 初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpUI()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK:- 搭建界面
    private func setUpUI() {
        //  图片布局
        contentView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        addConstraint(NSLayoutConstraint(item: imageView,
                                         attribute: .leading,
                                         relatedBy: .equal,
                                         toItem: contentView,
                                         attribute: .leading,
                                         multiplier: 1,
                                         constant: 0))
        
        addConstraint(NSLayoutConstraint(item: imageView,
                                         attribute: .top,
                                         relatedBy: .equal,
                                         toItem: contentView,
                                         attribute: .top,
                                         multiplier: 1,
                                         constant: 0))
        
        addConstraint(NSLayoutConstraint(item: imageView,
                                         attribute: .trailing,
                                         relatedBy: .equal,
                                         toItem: contentView,
                                         attribute: .trailing,
                                         multiplier: 1,
                                         constant: 0))
        
        addConstraint(NSLayoutConstraint(item: imageView,
                                         attribute: .bottom,
                                         relatedBy: .equal,
                                         toItem: contentView,
                                         attribute: .bottom,
                                         multiplier: 1,
                                         constant: 0))
    }
}
