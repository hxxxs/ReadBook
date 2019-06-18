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
    var `id` = ""
    var md = ""
    var cmd = ""
    var offset = 0
    var encodeUrl = ""
    var picUrl = ""
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        title <- map["title"]
        id <- map["id"]
        md <- map["md"]
        cmd <- map["cmd"]
        offset <- map["offset"]
        encodeUrl <- map["encodeUrl"]
        picUrl <- map["picUrl"]
    }
}
