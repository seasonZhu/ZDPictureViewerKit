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
public let ZDPictureViewerBundle: Bundle? = {
    let bundle = Bundle(path: Bundle(for: ZDPictureBrowseView.classForCoder()).resourcePath! + "/ZDPictureViewer.bundle")
    return bundle
}()
