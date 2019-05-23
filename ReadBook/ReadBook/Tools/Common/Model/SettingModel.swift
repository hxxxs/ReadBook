//
//  SettingModel.swift
//  ReadBook
//
//  Created by 123 on 2019/5/16.
//  Copyright © 2019 hxs. All rights reserved.
//

import UIKit

let kTextFontKey = "kTextFontKey"

class SettingModel {
    static var textFontSize: CGFloat {
        let fontSize = UserDefaults.standard.integer(forKey: kTextFontKey)
        return fontSize > 0 ? CGFloat(fontSize) : 24
    }
}
