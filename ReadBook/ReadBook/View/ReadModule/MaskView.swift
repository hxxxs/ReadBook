//
//  MaskView.swift
//  ReadBook
//
//  Created by 123 on 2019/5/16.
//  Copyright © 2019 hxs. All rights reserved.
//

import UIKit

class MaskView: UIView {
    
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
        
        addFontButton.setTitle("\u{e60f}", for: .normal)
        addFontButton.titleLabel?.font = UIFont(name: "iconFont", size: 30)
        reduceFontButton.setTitle("\u{e60e}", for: .normal)
        reduceFontButton.titleLabel?.font = UIFont(name: "iconFont", size: 30)
        playerButton.setTitle("\u{e610}", for: .normal)
        playerButton.titleLabel?.font = UIFont(name: "iconFont", size: 30)
    }
    
    func chapterButtonEnable(previous: Bool, next: Bool) {
        previousButton.isEnabled = previous
        nextButton.isEnabled = next
    }
    
    @IBAction func buttonsClick(_ sender: UIButton) {
        monitorCompletion?(sender.tag)
    }
}
