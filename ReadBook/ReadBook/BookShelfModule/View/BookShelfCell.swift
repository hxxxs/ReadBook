//
//  BookShelfCell.swift
//  ReadBook
//
//  Created by 123 on 2019/5/17.
//  Copyright © 2019 hxs. All rights reserved.
//

import UIKit
import SDWebImage

class BookShelfCell: UITableViewCell {

    var model: BookInfoModel! {
        didSet {
            if let url = URL(string: model.picUrl) {
                imageView?.sd_setImage(with: url, placeholderImage: UIImage(imageLiteralResourceName: "noData"))
            }
            textLabel?.text = model.title
        }
    }
    
    override func layoutSubviews() {
        
        imageView?.snp.makeConstraints({ (make) in
            make.left.equalTo(10)
            make.centerY.equalToSuperview()
            make.height.equalTo(100)
            make.width.equalTo(75)
        })
        
        textLabel?.snp.makeConstraints({ (make) in
            make.left.equalTo(imageView!.snp.right).offset(10)
            make.centerY.equalToSuperview()
        })
    }
    
}
