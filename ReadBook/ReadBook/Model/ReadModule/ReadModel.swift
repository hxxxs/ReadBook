//
//  ReadModel.swift
//  ReadBook
//
//  Created by 123 on 2019/5/15.
//  Copyright © 2019 hxs. All rights reserved.
//  阅读模型

import UIKit
import ObjectMapper

class ReadModel: Mappable {
    var title = ""
    var content = ""
    var next_cid = ""
    var next_url = ""
    var pre_cid = ""
    var pre_url = ""
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        title <- map["title"]
        content <- map["content"]
        next_cid <- map["pt.next_cid"]
        next_url <- map["pt.next_url"]
        pre_cid <- map["pt.pre_cid"]
        pre_url <- map["pt.pre_url"]
    }
}

