//
//  BookShelfCell.swift
//  ReadBook
//
//  Created by 123 on 2019/5/17.
//  Copyright © 2019 hxs. All rights reserved.
//  书架单元格

import UIKit
import SDWebImage

class BookShelfCell: UICollectionViewCell {

    /// 书信息模型
    var model: BookInfoModel! {
        didSet {
            if let url = URL(string: model.picUrl) {
                imageView.sd_setImage(with: url, placeholderImage: UIImage(imageLiteralResourceName: "noData"))
            } else {
                imageView.image = UIImage(imageLiteralResourceName: "noData")
            }
            textLabel.text = model.title
            offsetLabel.text = "\(model.offset)"
        }
    }
    
    /// 章节标签
    private lazy var offsetLabel: UILabel = {
        let label = UILabel(textColor: UIColor.darkGray)
        label.backgroundColor = UIColor.white
        return label
    }()
    /// 图片
    private lazy var imageView = UIImageView(image: UIImage(imageLiteralResourceName: "noData"))
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
            offsetLabel.isHidden = showDeleteButton
            if !showDeleteButton {            
                imageView.animationShaker()
            }
        }
    }
    
    /// 删除按钮点击回调
    var deleteButtonCallBack: ((BookInfoModel) -> ())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(imageView)
        contentView.addSubview(textLabel)
        contentView.addSubview(deleteButton)
        contentView.addSubview(offsetLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
        
        offsetLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(imageView)
            make.centerX.equalTo(imageView)
        }
    }
    
}

// MARK: - Monitor

extension BookShelfCell {
    
    /// 删除按钮点击
    @objc func deleteButtonClick() {
        deleteButtonCallBack?(model)
    }
}
