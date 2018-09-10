//
//  ZDPictureBrowseView.swift
//  ZDPicViewerDemo
//
//  Created by season on 2018/9/7.
//  Copyright © 2018年 season. All rights reserved.
//

import UIKit
import Kingfisher

public class ZDPictureBrowseView: UIView {
    
    //MARK:- 属性设置
    
    ///  复用Identifier
    private let cellIdentifier = String(describing: type(of: ZDPictureBrowseCell.self))

    ///  用来放置各个图片单元
    private lazy var collectionView: UICollectionView = {
        
        //  collectionView尺寸样式设置
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = bounds.size
        layout.scrollDirection = .horizontal
        
        //  collectionView初始化
        let collectionView = UICollectionView(frame: bounds, collectionViewLayout: layout)
        collectionView.register(ZDPictureBrowseCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.showsVerticalScrollIndicator = false
        
        //  滚动到点击的图片页面
        collectionView.scrollToItem(at: currentIndexPath, at: .right, animated: false)
        
        return collectionView
    }()
    
    //  topLabel
    private lazy var topLabel: UILabel = {
        let label = UILabel()
        label.frame = CGRect(x: 40, y: UIApplication.shared.statusBarFrame.height, width: frame.width - 80, height: 30)
        label.text =  "\(currentIndexPath.item + 1)/\(imageInfos.count)"
        label.textColor = UIColor.white;
        label.textAlignment = .center;
        label.font = UIFont.systemFont(ofSize: 17);
        return label
    }()
    
    //  rightButton
    private lazy var rightButton: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x:self.frame.width - 40, y: UIApplication.shared.statusBarFrame.height, width: 20, height: 30)
        button.setImage(UIImage(named: "menu", in: ZDPictureViewerBundle, compatibleWith: nil), for: .normal)
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(rightButtonAction(_:)), for: .touchUpInside)
        return button
    }()
    
    //  背景
    private lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black
        return view
    }()
    
    //  大图
    private lazy var bigImageView: AnimatedImageView = {
        let imageView = AnimatedImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    //  小图
    private lazy var smallImageView: AnimatedImageView = {
        let imageView = AnimatedImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    //  是否是Url
    private var isUrl: Bool!
    
    //  图片信息数组
    private var imageInfos: [String]!
    
    //  当前的currentIndexPath
    private var currentIndexPath: IndexPath!
    
    //  父类的控制器
    private var parentVC: UIViewController!
    
    //  占位图
    private var placeholder: UIImage?
    
    private var selectCallback: ((IndexPath) -> (AnimatedImageView))!
    
    private var rightButtonAction: ((UIImage?) -> ())?
    
    private var longPressAction: ((UIImage?, UILongPressGestureRecognizer) -> ())?
    
    //  初始化
    @discardableResult
    public class func show(isUrl: Bool,
                           imageInfos: [String],
                           currentIndexPath: IndexPath,
                           parentVC: UIViewController,
                           placeholder: UIImage?,
                           rightButtonAction: ((UIImage?) -> ())? = nil,
                           longPressAction: ((UIImage?, UILongPressGestureRecognizer) -> ())? = nil,
                           selectCallback: @escaping ((IndexPath) -> (AnimatedImageView))) -> ZDPictureBrowseView {
        
        let pictureBrowseView = ZDPictureBrowseView(frame: parentVC.view.bounds)
        pictureBrowseView.isUrl = isUrl
        pictureBrowseView.imageInfos = imageInfos
        pictureBrowseView.currentIndexPath = currentIndexPath
        pictureBrowseView.parentVC = parentVC
        pictureBrowseView.placeholder = placeholder
        pictureBrowseView.rightButtonAction = rightButtonAction
        pictureBrowseView.longPressAction = longPressAction
        pictureBrowseView.selectCallback = selectCallback
        pictureBrowseView.show()
        return pictureBrowseView
    }
    
    //  私有化 因为传参的缘故 必须使用类方法进行初始化
    private override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //  析构函数
    deinit {
        print("ZDPictureBrowseView销毁了")
    }
}

extension ZDPictureBrowseView {
    private func show() {
        parentVC.view.addSubview(self)
        loadBackgroundView()
        
        UIView.animate(withDuration: 0.3, animations: {
            self.backgroundView.alpha = 1
            self.setBigImageViewFrame()
        }) { (_) in
            self.setUpUI()
        }
    }
    
    //MARK:- 搭建背景
    private func loadBackgroundView() {
        
        smallImageView = selectCallback(currentIndexPath)
        
        guard let image = smallImageView.image else { return }
        let vcFrame = smallImageView.convert(smallImageView.bounds, to: self)
        bigImageView.frame = vcFrame
        bigImageView.image = image
        
        backgroundView.addSubview(bigImageView)
        backgroundView.alpha = 0
        backgroundView.frame = bounds
        addSubview(backgroundView)
    }
    
    //  设置大图的frame
    private func setBigImageViewFrame() {
        if bigImageView.image == nil || bigImageView.image?.size.width == 0 || bigImageView.image?.size.height == 0 {
            return
        }
        
        guard let size = bigImageView.image?.size else {
            return
        }
        
        if size.width / frame.width > size.height / frame.height {
            bigImageView.frame.size.width = frame.width
            bigImageView.frame.size.height = bigImageView.frame.width * size.height / size.width
        }else{
            bigImageView.frame.size.height = frame.height
            bigImageView.frame.size.width = bigImageView.frame.height * size.width / size.height
        }
        
        bigImageView.center = center
    }
    
    //MARK:- 搭建界面
    private func setUpUI() {
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            self.backgroundView.alpha = 0
            self.backgroundView.backgroundColor = .clear
            self.sendSubview(toBack: self.backgroundView)
        }
        
        addSubview(collectionView)
        addSubview(topLabel)
        addSubview(rightButton)
        
        backgroundColor = .clear
        bringSubview(toFront: backgroundView)
    }
    
    //MARK:- 隐藏并移除
    func tapHiddenPicView(index: Int) {
        
        collectionView.removeFromSuperview()
        topLabel.removeFromSuperview()
        rightButton.removeFromSuperview()
        
        smallImageView = selectCallback(currentIndexPath)
        
        if let image = smallImageView.image {
            bigImageView.image = image
        }
        
        backgroundView.alpha = 1
        
        UIView.animate(withDuration: 0.3, animations: {
            self.backgroundView.backgroundColor = UIColor.clear
            let vcFrame = self.smallImageView.convert(self.smallImageView.bounds, to: self.parentVC.view)
            self.bigImageView.frame = vcFrame
        }) { (_) in
            self.removeFromSuperview()
        }
    }
    
    //MARK:- 按钮的点击事件
    @objc
    private func rightButtonAction(_ button: UIButton) {
        let image = (collectionView.cellForItem(at: currentIndexPath) as? ZDPictureBrowseCell)?.imageView.image
        rightButtonAction?(image)
    }
    
    //MARK:- 长按的手势事件
    private func longPress(_ gestureRecognizer: UILongPressGestureRecognizer) {
        let image = (collectionView.cellForItem(at: currentIndexPath) as? ZDPictureBrowseCell)?.imageView.image
        longPressAction?(image, gestureRecognizer)
    }
}

extension ZDPictureBrowseView: UICollectionViewDataSource {
    //  collectionView单元区域数量
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    //  collectionView单元格数量
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageInfos.count
    }
    
    //  collectionView单元格创建
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! ZDPictureBrowseCell
        //  这里一定要先写isUrl赋值,再写imageInfo的赋值 其实应该创建一个模型
        cell.isUrl = isUrl
        cell.imageInfo = imageInfos[indexPath.item]
        cell.tag = kCommonTag + indexPath.item
        
        cell.gestureCallback = { [weak self] (index, isGoBack) in
            
            self?.currentIndexPath = IndexPath(item: index, section: 0)
            if isGoBack {
                self?.tapHiddenPicView(index: index)
            }else {
                guard let button = self?.rightButton else { return }
                self?.rightButtonAction(button)
            }
        }
        
        cell.panCallback = { [weak self] (progress, panFrame) in
            self?.collectionView.backgroundColor = UIColor.black.withAlphaComponent(progress)
            self?.bigImageView.frame = panFrame
            self?.collectionView.isScrollEnabled = progress == 1.0
        }
        
        cell.longPressCallback = { [weak self] gestureRecognizer in
            self?.longPress(gestureRecognizer)
        }
        
        return cell
    }
}

extension ZDPictureBrowseView: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        currentIndexPath = indexPath
        topLabel.text = "\(currentIndexPath.item + 1)/\(imageInfos.count)"
    }
}
