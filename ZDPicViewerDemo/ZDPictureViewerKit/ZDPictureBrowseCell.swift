//
//  ZDPictureBrowseCell.swift
//  ZDPicViewerDemo
//
//  Created by season on 2018/9/7.
//  Copyright © 2018年 season. All rights reserved.
//

import UIKit
import Kingfisher

class ZDPictureBrowseCell: UICollectionViewCell {
    //MARK:- 属性设置
    
    //  是否是Url
    var isUrl = false
    
    //  图片信息 url或者是name
    var imageInfo: String {
        set {
            newImageInfo = newValue
            if isUrl {
                
                let isCache = KingfisherManager.shared.cache.imageCachedType(forKey: newValue).cached
                
                if !isCache {
                    //  菊花转
                }
                
                guard let url = URL.init(string: newValue) else {
                    return
                }
                
                imageView.kf.setImage(with: url, placeholder: nil, options: [.backgroundDecode], progressBlock: { (receivedSize, totalSize) in
                    
                }) { [weak self] (image, error, type, url) in
                    
                    if !isCache {
                        //  菊花停止
                    }
                    
                    guard let unwrappedImage = image else {
                        return
                    }
                    
                    self?.loadImageViewSize(image: unwrappedImage)
                }
            }else {
                imageView.image = UIImage(named: newValue)!
                loadImageViewSize(image: imageView.image!)
            }
        }get {
            return newImageInfo
        }
    }
    
    private var newImageInfo = ""
    
    //  手势回调
    var gestureCallback: ((_ tag: Int, _ isGoBack: Bool) -> ())?
    
    //  滑动回调
    var panCallback: ((_ progress: CGFloat, _ imageViewFrame: CGRect) -> ())?
    
    //  移动的图片
    private var moveImageView: AnimatedImageView?
    
    //  是否是放大
    private var isZooming = false
    
    //  是否是滑动
    private var isPanning = false
    
    //  是否是方向向下
    private var directionIsDown = false
    
    //  进度 progress
    private var progress: CGFloat = 1.0 {
        willSet {
            guard let imageView = moveImageView else {
                return
            }
            panCallback?(1.0 - newValue, imageView.frame)
        }
    }
    
    //  滑动时最后一次的Y坐标
    private var panLastY: CGFloat = 0
    
    //  滑动时最初的坐标
    private var panBeginPoint = CGPoint.zero
    
    //  图片最初的rect
    private var imageBeginFrame = CGRect.zero
    
    //  min scaling ratio
    let imageMinZoom: CGFloat = 0.3
    
    //  0.0-1.0
    let imagePanningSpeed: CGFloat = 1.0
    
    //  图片view
    lazy var imageView: AnimatedImageView = {
        let imageView = AnimatedImageView()
        imageView.frame = bounds
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        
        //  手势
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(singleTapAction(_:)))
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(doubleTapAction(_:)))
        let twoFingerTap = UITapGestureRecognizer(target: self, action: #selector(twoFingerTapAction(_:)))
        let longPressTap = UILongPressGestureRecognizer(target: self, action: #selector(longPressTapAction(_:)))
        
        singleTap.numberOfTapsRequired = 1;
        singleTap.numberOfTouchesRequired = 1;
        doubleTap.numberOfTapsRequired = 2;
        twoFingerTap.numberOfTouchesRequired = 2;
        singleTap.require(toFail: doubleTap)
        
        imageView.addGestureRecognizer(singleTap)
        imageView.addGestureRecognizer(doubleTap)
        imageView.addGestureRecognizer(twoFingerTap)
        imageView.addGestureRecognizer(longPressTap)
        
        return imageView
    }()
    
    //  scrollView
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.frame = bounds
        scrollView.delegate = self
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 3.0
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceVertical = true
        scrollView.alwaysBounceHorizontal = true
        scrollView.contentSize = bounds.size
        scrollView.setZoomScale(1, animated: false)
        scrollView.contentOffset = CGPoint(x: 0, y: 0)
        scrollView.addSubview(imageView)
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        return scrollView
    }()
    
    //MARK:- 初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(scrollView)
        
        // 自身也要添加一个手势 点击返回
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(singleTapAction(_:)))
        addGestureRecognizer(singleTap)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK:- 手势事件
    
    //  单击事件
    @objc
    private func singleTapAction(_ gestureRecognizer: UITapGestureRecognizer) {
        
        print("singleTapAction")
        
        if gestureRecognizer.numberOfTapsRequired == 1  {
            gestureCallback?(tag - kCommonTag, true)
        }
    }
    
    //  双击事件
    @objc
    private func doubleTapAction(_ gestureRecognizer: UITapGestureRecognizer) {
        
        print("doubleTapAction")
        
        if gestureRecognizer.numberOfTapsRequired == 2 {
            
            if scrollView.zoomScale == 1{
                let newScale = scrollView.zoomScale * 3.0
                let zoomRect = zoomRectForScale(newScale, gestureRecognizer.location(in: gestureRecognizer.view))
                scrollView.zoom(to: zoomRect, animated: true)
            }else {
                let newScale = scrollView.zoomScale / 3.0
                let zoomRect = zoomRectForScale(newScale, gestureRecognizer.location(in: gestureRecognizer.view))
                scrollView.zoom(to: zoomRect, animated: true)
            }
        }
    }
    
    //  两个手指的事件
    @objc
    private func twoFingerTapAction(_ gestureRecognizer:UITapGestureRecognizer) {
        print("twoFingerTapAction")
        let newScale = scrollView.zoomScale / 3.0
        let zoomRect = zoomRectForScale(newScale, gestureRecognizer.location(in: gestureRecognizer.view))
        scrollView.zoom(to: zoomRect, animated: true)
    }
    
    //  长按事件
    @objc
    private func longPressTapAction(_ gestureRecognizer: UILongPressGestureRecognizer) {
        print("longPressTapAction")
    }
    
    //  滑动事件
    private func panAction(_ gestureRecognizer: UIPanGestureRecognizer) {
        
        //  滑动结束或者有可能
        if gestureRecognizer.state == .ended || gestureRecognizer.state == .possible {
            panBeginPoint = CGPoint.zero
            isPanning = false
            return
        }
        
        //  两指
        if gestureRecognizer.numberOfTouches != 1 || isZooming {
            moveImageView = nil
            isPanning = false
            panBeginPoint = CGPoint.zero
            return
        }
        
        //  开始滑动
        if panBeginPoint == CGPoint.zero {
            panBeginPoint = gestureRecognizer.location(in: self)
            isPanning = true
            scrollView.isHidden = true
            imageBeginFrame = imageView.frame
        }
        
        if moveImageView == nil {
            moveImageView = AnimatedImageView(frame: imageView.frame)
            moveImageView?.contentMode = .scaleAspectFill
            moveImageView?.layer.masksToBounds = true
            moveImageView?.image = imageView.image
            addSubview(moveImageView!)
        }
        
        let panCurrentPoint = gestureRecognizer.location(in: self)
        
        //  判断是否是向下滑动
        directionIsDown = panCurrentPoint.y > panLastY
        
        panLastY = panCurrentPoint.y
        
        progress = (panCurrentPoint.y - panBeginPoint.y) / (frame.height / (1 + imagePanningSpeed))
        
        if panCurrentPoint.y > panBeginPoint.y {
            
            let zoomWidth = imageBeginFrame.width - (imageBeginFrame.width - imageBeginFrame.width * imageMinZoom) * progress
            let zoomHeight = imageBeginFrame.height - (imageBeginFrame.height - imageBeginFrame.height * imageMinZoom) * progress
            let minWidth = imageBeginFrame.width * imageMinZoom
            let minHeight = imageBeginFrame.height * imageMinZoom
            
            moveImageView?.frame.size.width = zoomWidth < minWidth ? minWidth : zoomWidth
            moveImageView?.frame.size.height = zoomHeight < minHeight ? minHeight : zoomHeight
        }
        else {
            moveImageView?.frame.size.width = imageBeginFrame.width
            moveImageView?.frame.size.height = imageBeginFrame.height
        }
        
        moveImageView?.frame.origin.x = (panBeginPoint.x - imageBeginFrame.origin.x) / imageBeginFrame.width * (imageBeginFrame.width - moveImageView!.frame.width) + (panCurrentPoint.x - panBeginPoint.x) + imageBeginFrame.origin.x
        
        moveImageView?.frame.origin.y = (panBeginPoint.y - imageBeginFrame.origin.y) / imageBeginFrame.height * (imageBeginFrame.height - moveImageView!.frame.height) + (panCurrentPoint.y - panBeginPoint.y) + imageBeginFrame.origin.y
    }
    
    //  滑动结束的事件
    private func endPanAction() {
        if directionIsDown {
            gestureCallback?(tag - kCommonTag, true)
        }else {
            guard let imageView = moveImageView else { return }
            UIView.animate(withDuration: TimeInterval(fabs(imageView.frame.origin.y - imageBeginFrame.origin.y) / (frame.height * 2)), animations: {
                self.moveImageView?.frame = self.imageBeginFrame
                self.progress = 0.0
            }, completion: { (_) in
                self.scrollView.contentOffset = CGPoint.zero
                self.scrollView.isHidden = false

                self.panBeginPoint = CGPoint.zero
                
                self.moveImageView?.isHidden = true
                self.moveImageView = nil
            })
        }
    }
    
    //MARK:- 析构函数
    deinit {
        print("ZDPictureBrowseCell销毁了")
    }
}

extension ZDPictureBrowseCell {
    
    private func loadImageViewSize(image: UIImage) {
        
        imageView.image = image
        
        if (image.size.width == 0 || image.size.height == 0) {
            return
        }
        
        let size = image.size
        
        if (size.width) / self.frame.width > (size.height) / self.frame.height {
            imageView.frame.size.width = self.frame.width
            imageView.frame.size.height = (imageView.frame.width) * (size.height) / (size.width)
        }else{
            imageView.frame.size.height = self.frame.height
            imageView.frame.size.width = (imageView.frame.height) * (size.width) / (size.height)
        }
        
        imageView.center = scrollView.center
        
    }
    
    private func zoomRectForScale(_ scale: CGFloat, _ center: CGPoint) -> CGRect {
        let width = scrollView.frame.width / scale
        let height = scrollView.frame.height / scale
        return CGRect(x: center.x - width / 2.0, y: center.y - height / 2.0, width: width, height: height)
    }
}

extension ZDPictureBrowseCell: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width) ? (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0
        let offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height) ? (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0
        imageView.center = CGPoint(x: scrollView.contentSize.width * 0.5 + offsetX, y: scrollView.contentSize.height * 0.5 + offsetY);
    }
    
    func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        isZooming = true
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        scrollView.setZoomScale(scale + 0.01, animated: false)
        scrollView.setZoomScale(scale, animated: false)
        isZooming = false
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.y < 0 || isPanning) && !isZooming {
            panAction(scrollView.panGestureRecognizer)
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if isPanning {
            endPanAction()
        }
    }
}
