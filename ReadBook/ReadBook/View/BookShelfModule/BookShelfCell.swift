//
//  BookShelfCell.swift
//  ReadBook
//
//  Created by 123 on 2019/5/17.
//  Copyright © 2019 hxs. All rights reserved.
//  书架单元格

import UIKit

class BookShelfCell: UICollectionViewCell {

    /// 书信息模型
    var model: BookInfoModel! {
        didSet {
            imageView.kf.setImage(with: URL(string: model.picUrl), placeholder: UIImage(imageLiteralResourceName: "noData"))
            textLabel.text = model.title
        }
    }
    
    /// 图片
    private lazy var imageView = UIImageView()
    /// 标题
    private lazy var textLabel = UILabel(font: UIFont.systemFont(ofSize: 20), textColor: UIColor.darkGray, textAlignment: .center)
    /// 删除按钮
    private lazy var deleteButton = UIButton(title: "\u{e613}", titleColor: UIColor.red, bgImage: UIImage.create(color: .white), font: UIFont(name: "iconFont", size: 20)!, target: self, action: #selector(deleteButtonClick), type: .custom)
    
    /// 书封面
    var bookImage: UIImage {
        return imageView.image!
    }
    
    /// 是否展示删除按钮
    var showDeleteButton = true {
        didSet {
            deleteButton.isHidden = showDeleteButton
            if !showDeleteButton {            
                imageView.animationShaker()
            }
        }
    }
    
    /// 删除按钮点击回调
    var deleteButtonCallBack: ((BookInfoModel) -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.snp.makeConstraints { (make) in
            make.top.equalTo(10)
            make.centerX.equalToSuperview()
            make.height.equalTo(100)
            make.width.equalTo(75)
        }

        textLabel.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(imageView.snp.bottom).offset(10)
        }
        
        deleteButton.snp.makeConstraints { (make) in
            make.centerX.equalTo(imageView.snp.right)
            make.centerY.equalTo(imageView.snp.top)
        }
    }
    
    private func setup() {
        contentView.addSubview(imageView)
        contentView.addSubview(textLabel)
        contentView.addSubview(deleteButton)
    }
    
}

// MARK: - Monitor

extension BookShelfCell {
    
    /// 删除按钮点击
    @objc func deleteButtonClick() {
        deleteButtonCallBack?(model)
    }
}
