//
//  IconFont.swift
//  ReadBook
//
//  Created by 123 on 2019/6/10.
//  Copyright © 2019 hxs. All rights reserved.
//

import UIKit

/// 字体加
public let addFontTitle = "\u{e60f}"
/// 字体减
public let reduceFontTitle = "\u{e60e}"
/// 朗读
public let speechTitle = "\u{e610}"

public func IconFont(ofSize size: CGFloat) -> UIFont {
    return UIFont(name: "iconFont", size: size) ?? UIFont.systemFont(ofSize: size)
}
