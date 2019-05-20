//
//  BookShelfModel.swift
//  ReadBook
//
//  Created by 123 on 2019/5/20.
//  Copyright © 2019 hxs. All rights reserved.
//

import Foundation

struct BookShelfModel {
    static let shared = BookShelfCell()
    
    lazy var books: [BookInfoModel] = {
        let array = [BookInfoModel]()
        return array
    }()
}
