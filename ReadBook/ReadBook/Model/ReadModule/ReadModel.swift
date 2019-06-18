//
//  ReadModel.swift
//  ReadBook
//
//  Created by 123 on 2019/5/15.
//  Copyright © 2019 hxs. All rights reserved.
//  阅读模型

import UIKit

class ReadModel: HandyJSON {
    var previous = PreviousModel()
    var current = CurrentModel()
    var next = NextModel()
    var chapter = ChapterModel()
    required init() {}
}

class ChapterModel: HandyJSON {
    var content = ""
    required init() {}
}

class PreviousModel: HandyJSON {
    var cmd = ""
    var url = ""
    var encodeUrl = ""
    var offset: Int = -1
    var title = ""
    required init() {}
}

class CurrentModel: HandyJSON {
    var cmd = ""
    var url = ""
    var encodeUrl = ""
    var offset: Int = -1
    var title = ""
    required init() {}
}

class NextModel: HandyJSON {
    var cmd = ""
    var url = ""
    var encodeUrl = ""
    var offset: Int = -1
    var title = ""
    required init() {}
}
