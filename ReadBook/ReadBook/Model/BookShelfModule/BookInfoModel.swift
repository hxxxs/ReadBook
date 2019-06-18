//
//  BookInfoModel.swift
//  ReadBook
//
//  Created by 123 on 2019/5/15.
//  Copyright © 2019 hxs. All rights reserved.
//  书本信息模型

import UIKit

class BookInfoModel: HandyJSON {
    var title = ""
    var `id` = ""
    var md = ""
    var cmd = ""
    var offset = 0
    var encodeUrl = ""
    var picUrl = ""
    required init() {}
}
