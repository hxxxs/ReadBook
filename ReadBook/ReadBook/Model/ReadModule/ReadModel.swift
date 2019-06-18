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
    var previousOffset = -1
    var nextOffset = -1
    var offset: Int = -1
    var title = ""
    var content = ""
    
    required init?(map: Map) {}
    
    func mapping(map: Map) {
        content <- map["chapter.content"]
        previousOffset <- map["previous.offset"]
        nextOffset <- map["next.offset"]
        title <- map["current.title"]
        offset <- map["current.offset"]
    }
}

