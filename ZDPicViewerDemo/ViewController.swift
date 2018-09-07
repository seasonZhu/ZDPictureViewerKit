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
    private let cellIdentifier = "cellIdentifier"
    
    private var dataSource = [String]()
    
    private var collectionView : UICollectionView?
    
    private var resultCallback: ((String) -> (UIImage?))? {
        didSet {
            isUrl = resultCallback == nil
        }
    }
    
    private var isUrl: Bool = false
    
    private var changeButton: UIButton!
    
    private let imageUrlArray = ["http://pic.qiantucdn.com/58pic/18/85/34/56561c9192d9f_1024.jpg",
                                 "http://wx2.sinaimg.cn/mw690/a1eface5ly1frjxl0pja4j21kw11xb29.jpg",
                                 "http://pic.qqtn.com/up/2017-2/201702131606225644712.png",
                                 "http://www.tupianzj.com/uploads/Bizhi/mn2_1680.jpg",
                                 "http://imgsrc.baidu.com/image/c0%3Dpixel_huitu%2C0%2C0%2C294%2C40/sign=87efb04af0f2b211f0238d0ea3f80054/2e2eb9389b504fc242b5663ceedde71190ef6d25.jpg",
                                 "http://img.zcool.cn/community/033ee1a554c723d00000158fc2f64fe.jpg",
                                 "http://wx2.sinaimg.cn/mw690/a1eface5ly1frjxl5otbsj21kw11xe81.jpg",
                                 "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1536310847436&di=bf33c2b4618e53755b39283c750a9f66&imgtype=0&src=http%3A%2F%2Fimg.zcool.cn%2Fcommunity%2F01e8fa5965991ba8012193a3195e5a.gif",]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadLocalData()
        initCollectionView()
        initChangeImageTypeButton()
    }
    
    // MARK:
    func loadLocalData() {
        dataSource.removeAll()
        
        for _ in 1...7 {
            for j in 1...7 {
                dataSource.append(String(format:"%03zd.jpg",j))
            }
        }
        
        resultCallback = { (name) -> (UIImage?) in
            return UIImage(named: name)
        }
    }
    
    func loadUrlData() {
        dataSource.removeAll()
        
        for _ in 1...7 {
            for url in imageUrlArray {
               dataSource.append(url)
            }
        }
        
        resultCallback = nil
    }
    
    // MARK:UI
    func initCollectionView() {
        
        collectionView?.removeFromSuperview()
        collectionView = nil
        let defaultLayout = UICollectionViewFlowLayout()
        defaultLayout.scrollDirection = UICollectionViewScrollDirection.vertical
        collectionView = UICollectionView(frame: CGRect(x:45.0/4.0, y:UIApplication.shared.statusBarFrame.height + 44, width:kScreenWidth - 45.0/2.0, height:kScreenHeight - (UIApplication.shared.statusBarFrame.height + 44)), collectionViewLayout: defaultLayout)
        collectionView?.backgroundColor = UIColor.white
        collectionView?.register(ZDPictureViewCell.self, forCellWithReuseIdentifier: cellIdentifier)
        collectionView?.dataSource = self
        collectionView?.delegate = self
        collectionView?.showsVerticalScrollIndicator =  false
        collectionView?.showsHorizontalScrollIndicator = false
        view.addSubview(collectionView!)
        
    }
    
    func initChangeImageTypeButton() {
        let button = UIButton(frame: CGRect(x: 50, y: kScreenHeight - 100, width: kScreenWidth - 100, height: 40))
        button.addTarget(self, action: #selector(changeImageTypeButtonAction(_ :)), for: UIControlEvents.touchUpInside)
        button.backgroundColor = UIColor.lightGray
        button.setTitle("change to web pictures", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.layer.cornerRadius = button.frame.height/2.0
        view.addSubview(button)
        self.changeButton = button
    }

    
    //MARK:- 按钮的点击事件
    @objc
    func changeImageTypeButtonAction(_ button :UIButton) {
        button.isSelected = !button.isSelected
        button.setTitle(button.isSelected ? "change to lcoal pictures" : "change to web pictures", for: .normal)
        button.isSelected == true ? loadUrlData() : loadLocalData()
        collectionView?.reloadData()
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
                                       options: [.backgroundDecode],
                                       progressBlock: nil,
                                       completionHandler: nil)
        }else {
            cell.imageView.image = resultCallback?(dataSource[indexPath.row])
        }
        return cell;
    }
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        ZDPictureBrowseView.show(isUrl: changeButton.isSelected, imageInfos: dataSource, currentIndexPath: indexPath, parentVC: self, placeholder: nil, runable: {
            print("点击了右侧按钮")
        }) { (callbackIndexPaht) -> (AnimatedImageView) in
            guard let cell = collectionView.cellForItem(at: callbackIndexPaht) as? ZDPictureViewCell else {
                return AnimatedImageView()
            }
            return cell.imageView
        }
    }
    
    
}


extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: kScreenWidth/3.0 - 15.0, height: kScreenWidth/3.0 - 15.0)
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

