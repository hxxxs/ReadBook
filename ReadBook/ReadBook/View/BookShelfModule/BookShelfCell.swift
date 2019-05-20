//
//  BookShelfCell.swift
//  ReadBook
//
//  Created by 123 on 2019/5/17.
//  Copyright © 2019 hxs. All rights reserved.
//

import UIKit
import SDWebImage

class BookShelfCell: UICollectionViewCell {

    var model: BookInfoModel! {
        didSet {
            if let url = URL(string: model.picUrl) {
                imageView.sd_setImage(with: url, placeholderImage: UIImage(imageLiteralResourceName: "noData"))
            }
            textLabel.text = model.title
        }
    }
    
    private lazy var imageView = UIImageView()
    private lazy var textLabel = UILabel(font: UIFont.systemFont(ofSize: 20), textColor: UIColor.darkGray, textAlignment: .center)
    private lazy var deleteButton: UIButton = {
        let btn = UIButton(title: "\u{e613}", titleColor: UIColor.red, bgImage: UIImage.create(color: .white), font: UIFont(name: "iconFont", size: 20)!, target: self, action: #selector(deleteButtonClick), type: .custom)
        return btn
    }()
    
    var showDeleteButton = true {
        didSet {
            deleteButton.isHidden = showDeleteButton
            if !showDeleteButton {            
                imageView.animationShaker()
            }
        }
    }
    
    var deleteButtonCallBack: ((BookInfoModel) -> ())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(imageView)
        contentView.addSubview(textLabel)
        contentView.addSubview(deleteButton)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.snp.makeConstraints({ (make) in
            make.top.equalTo(10)
            make.centerX.equalToSuperview()
            make.height.equalTo(100)
            make.width.equalTo(75)
        })

        textLabel.snp.makeConstraints({ (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(imageView.snp.bottom).offset(10)
        })
        
        deleteButton.snp.makeConstraints { (make) in
            make.centerX.equalTo(imageView.snp.right)
            make.centerY.equalTo(imageView.snp.top)
        }
    }
    
}

// MARK: - Monitor

extension BookShelfCell {
    
    @objc func deleteButtonClick() {
        deleteButtonCallBack?(model)
    }
}