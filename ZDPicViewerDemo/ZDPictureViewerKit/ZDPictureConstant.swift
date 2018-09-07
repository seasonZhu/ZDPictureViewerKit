//
//  ZDPictureConstant.swift
//  ZDPicViewerDemo
//
//  Created by season on 2018/9/7.
//  Copyright © 2018年 season. All rights reserved.
//

import UIKit

//  tag常量
let kCommonTag: Int = 1000


//  bundle
let ZDPictureViewerBundle: Bundle? = {
    let path = Bundle.main.path(forResource: "ZDPictureViewer", ofType: "bundle")
    let bundle = Bundle(path: path!)
    return bundle
}()

//  宽高
let kScreenWidth = UIScreen.main.bounds.width
let kScreenHeight = UIScreen.main.bounds.height
