//
//  BookInfoModel.swift
//  ReadBook
//
//  Created by 123 on 2019/5/15.
//  Copyright © 2019 hxs. All rights reserved.
//  书本信息模型

import UIKit
import ObjectMapper

class BookInfoModel: Mappable {
    var title = ""
    var gid = ""
    var cid = ""
    var url = ""
    var picUrl = ""
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        title <- map["title"]
        gid <- map["gid"]
        cid <- map["cid"]
        url <- map["url"]
        picUrl <- map["picUrl"]
    }
}
