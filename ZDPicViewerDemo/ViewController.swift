//
//  ViewController.swift
//  ZDPicViewerDemo
//
//  Created by season on 2018/9/6.
//  Copyright © 2018年 season. All rights reserved.
//

import UIKit
import Kingfisher

class ViewController: UIViewController {
    
    //MARK:- 属性设置
    private let cellIdentifier = String(describing: type(of: ZDPictureViewCell.self))
    
    private var dataSource = [String]()
    
    private var collectionView : UICollectionView?
    
    private var resultCallback: ((String) -> (UIImage?))? {
        didSet {
            isUrl = resultCallback == nil
        }
    }
    
    private var isUrl: Bool = false
    
    private var changeButton: UIButton!
    
    private var isBeginMove = false
    
    private var isShake = false
    
    private let imageUrlArray = ["http://pic.qiantucdn.com/58pic/18/85/34/56561c9192d9f_1024.jpg",
                                 "http://wx2.sinaimg.cn/mw690/a1eface5ly1frjxl0pja4j21kw11xb29.jpg",
                                 "http://pic.qqtn.com/up/2017-2/201702131606225644712.png",
                                 "http://www.tupianzj.com/uploads/Bizhi/mn2_1680.jpg",
                                 "http://imgsrc.baidu.com/image/c0%3Dpixel_huitu%2C0%2C0%2C294%2C40/sign=87efb04af0f2b211f0238d0ea3f80054/2e2eb9389b504fc242b5663ceedde71190ef6d25.jpg",
                                 "http://img.zcool.cn/community/033ee1a554c723d00000158fc2f64fe.jpg",
                                 "http://wx2.sinaimg.cn/mw690/a1eface5ly1frjxl5otbsj21kw11xe81.jpg",
                                 "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1536310847436&di=bf33c2b4618e53755b39283c750a9f66&imgtype=0&src=http%3A%2F%2Fimg.zcool.cn%2Fcommunity%2F01e8fa5965991ba8012193a3195e5a.gif",]
    
    //MARK:- viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        loadLocalData()
        setUpUI()
    }
    
    // MARK: - 加载图片的事件
    private func loadLocalData() {
        dataSource.removeAll()
        
        for _ in 1...7 {
            for j in 1...7 {
                dataSource.append(String(format:"%03zd.jpg",j))
            }
        }
        
        resultCallback = { name in
            return UIImage(named: name)
        }
    }
    
    private func loadUrlData() {
        dataSource.removeAll()
        
        for _ in 1...7 {
            for url in imageUrlArray {
               dataSource.append(url)
            }
        }
        
        resultCallback = nil
    }
    
    // MARK: -搭建界面
    private func setUpUI() {
        collectionView?.removeFromSuperview()
        collectionView = nil
        let defaultLayout = UICollectionViewFlowLayout()
        defaultLayout.scrollDirection = UICollectionViewScrollDirection.vertical
        collectionView = UICollectionView(frame: CGRect(x:45.0 / 4.0, y:UIApplication.shared.statusBarFrame.height + 44, width:UIScreen.main.bounds.width - 45.0 / 2.0, height:UIScreen.main.bounds.height - (UIApplication.shared.statusBarFrame.height + 44)), collectionViewLayout: defaultLayout)
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(ZDPictureViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView?.dataSource = self
        collectionView?.delegate = self
        collectionView?.showsVerticalScrollIndicator =  false
        collectionView?.showsHorizontalScrollIndicator = false
        view.addSubview(collectionView!)
        
        let button = UIButton(frame: CGRect(x: 50, y: UIScreen.main.bounds.height - 100, width: UIScreen.main.bounds.width - 100, height: 40))
        button.addTarget(self, action: #selector(changeImageTypeButtonAction(_ :)), for: UIControlEvents.touchUpInside)
        button.backgroundColor = UIColor.lightGray
        button.setTitle("切换到网络图片", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.layer.cornerRadius = button.frame.height/2.0
        view.addSubview(button)
        self.changeButton = button
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAction(_:)))
        tap.numberOfTapsRequired = 2
        view.addGestureRecognizer(tap)
    }
    
    
    //MARK:- 按钮的点击事件
    @objc
    private func changeImageTypeButtonAction(_ button :UIButton) {
        button.isSelected = !button.isSelected
        button.setTitle(button.isSelected ? "切换到本地图片" : "切换到网络图片", for: .normal)
        button.isSelected == true ? loadUrlData() : loadLocalData()
        collectionView?.reloadData()
    }
    
    //MARK:- 点击手势
    @objc
    private func tapAction(_ tap: UITapGestureRecognizer) {
        isShake = false

        for cell in collectionView!.visibleCells {
            stopShake(cell: cell)
        }
    }
    
    //MARK:- 长按手势
    @objc
    private func moveCell(_ gestureRecognizer: UILongPressGestureRecognizer) {
        switch gestureRecognizer.state {
        case .began:
            if !isBeginMove {
                isBeginMove = true
                guard let selectedIndexPath = collectionView?.indexPathForItem(at: gestureRecognizer.location(in: collectionView)) else { return }
                collectionView?.beginInteractiveMovementForItem(at: selectedIndexPath)
                
                
                isShake = true
//                collectionView?.reloadData()
                for cell in collectionView!.visibleCells {
                    startShake(cell: cell)
                }
            }
        case .changed:
            collectionView?.updateInteractiveMovementTargetPosition(gestureRecognizer.location(in: collectionView))
        case .ended:
            isBeginMove = false
            collectionView?.endInteractiveMovement()
        default:
            collectionView?.cancelInteractiveMovement()
        }
    }
}

extension ViewController {
    //MARK:- 动画效果
    private func startShake(cell: UICollectionViewCell) {
        let keyAnimation = CAKeyframeAnimation()
        keyAnimation.keyPath = "transform.rotation"
        keyAnimation.values = [-3 / 180.0 * Double.pi, 3 / 180.0 * Double.pi, -3 / 180.0 * Double.pi]
        keyAnimation.isRemovedOnCompletion = false
        keyAnimation.fillMode = kCAFillModeForwards
        keyAnimation.duration = 0.3
        keyAnimation.repeatCount = Float(Int.max)
        keyAnimation.autoreverses = true
        
        cell.layer.add(keyAnimation, forKey: "cellShake")
    }
    
    private func stopShake(cell: UICollectionViewCell) {
        cell.layer.removeAnimation(forKey: "cellShake")
    }
    
    //MARK:- 获取collectionView所有的cell,这个貌似只有在scrollViewDidScroll代理中使用
    private func getAllCell() -> [ZDPictureViewCell] {
        
        var cells = [ZDPictureViewCell]()
        
        let x = collectionView!.contentOffset.x
        let y = collectionView!.contentOffset.y
        let width = collectionView!.frame.width
        let height = collectionView!.frame.height
        let rect = CGRect(x: x, y: y, width: width, height: height)
        
        guard let views = collectionView!.subviews as? [UIView] else {
            return cells
        }
        
        for view in views {
            if rect.intersects(collectionView!.frame) {
                if let cell = view as? ZDPictureViewCell {
                    cells.append(cell)
                }
            }
        }
        
        return cells
    }
}

extension ViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return dataSource.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell{
        
        let cell  = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! ZDPictureViewCell
        //cell.imageView.tag = kCommonTag + indexPath.item
        
        if isUrl {
            cell.imageView.kf.setImage(with:URL.init(string: dataSource[indexPath.row] ),
                                       placeholder: UIImage(named: "placeholder", in: ZDPictureViewerBundle, compatibleWith: nil),
                                       options: [.backgroundDecode])
        }else {
            cell.imageView.image = resultCallback?(dataSource[indexPath.row])
        }
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(moveCell(_:)))
        cell.addGestureRecognizer(longPress)
        
        return cell;
    }
    
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let data = dataSource[sourceIndexPath.item]
        dataSource.remove(at: sourceIndexPath.item)
        dataSource.insert(data, at: destinationIndexPath.item)
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if isShake {
            startShake(cell: cell)
        }
    }
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        ZDPictureBrowseView.show(isUrl: changeButton.isSelected,
                                 imageInfos: dataSource,
                                 currentIndexPath: indexPath,
                                 parentVC: self,
                                 placeholder: nil,
                                 rightButtonAction: { image in
                                    //  这个runable是用于执行右侧上方的按钮点击事件
                                    print("点击了右侧按钮")
                                    print(image)
        },
                                 longPressAction: { image, gestureRecognizer in
                                    print("长按手势")
                                    print(image)
            
        }) { callbackIndexPaht in
            guard let cell = collectionView.cellForItem(at: callbackIndexPaht) as? ZDPictureViewCell else {
                return AnimatedImageView()
            }
            return cell.imageView
        }
    }
    
    
}

// MARK: - 使用代理进行layout设置
extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width / 3.0 - 15.0, height: UIScreen.main.bounds.width / 3.0 - 15.0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets{
        return UIEdgeInsetsMake(0, 0, 0, 0);
    }
}
