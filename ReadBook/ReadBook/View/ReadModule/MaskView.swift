//
//  MaskView.swift
//  ReadBook
//
//  Created by 123 on 2019/5/16.
//  Copyright © 2019 hxs. All rights reserved.
//  蒙版视图

import UIKit

class MaskView: UIView {
    
    /// 事件点击回调
    var monitorCompletion: ((_ type: Int) -> ())?
    
    //  MARK: - lazy

    /// 上一章
    @IBOutlet weak var previousButton: UIButton!
    
    /// 下一章
    @IBOutlet weak var nextButton: UIButton!
    
    /// 朗读
    @IBOutlet weak var playerButton: UIButton!
    
    /// 字体减小
    @IBOutlet weak var reduceFontButton: UIButton!
    
    /// 字体放大
    @IBOutlet weak var addFontButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        addFontButton.setTitle(addFontTitle, for: .normal)
        addFontButton.titleLabel?.font = IconFont(ofSize: 30)
        reduceFontButton.setTitle(reduceFontTitle, for: .normal)
        reduceFontButton.titleLabel?.font = IconFont(ofSize: 30)
        playerButton.setTitle(speechTitle, for: .normal)
        playerButton.titleLabel?.font = IconFont(ofSize: 30)
    }
    
    /// 章节按钮可点击状态
    ///
    /// - Parameters:
    ///   - previous: 上一章状态
    ///   - next: 下一章状态
    func chapterButtonEnable(previous: Bool, next: Bool) {
        previousButton.isEnabled = previous
        nextButton.isEnabled = next
    }
    
    /// 按钮点击事件
    @IBAction func buttonsClick(_ sender: UIButton) {
        monitorCompletion?(sender.tag)
    }
}
