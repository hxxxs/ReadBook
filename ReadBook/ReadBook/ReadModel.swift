//
//  ReadModel.swift
//  ReadBook
//
//  Created by 123 on 2019/5/15.
//  Copyright © 2019 hxs. All rights reserved.
//

import UIKit
import HandyJSON

class ReadModel: HandyJSON {
    var current = CurrentModel()
    var chapter = ChapterModel()
    required init() {}
}

class ChapterModel: HandyJSON {
    var content = ""
    required init() {}
}

class CurrentModel: HandyJSON {
    var cmd = ""
    var url = ""
    var encodeUrl = ""
    var offset: Int = 0
    var title = ""
    required init() {}
}
