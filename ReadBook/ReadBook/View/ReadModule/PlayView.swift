//
//  PlayView.swift
//  ReadBook
//
//  Created by 123 on 2019/5/30.
//  Copyright © 2019 hxs. All rights reserved.
//

import UIKit

class PlayView: UIView {
    
    /// 事件点击回调
    var monitorCompletion: ((_ view: UIView, _ type: Int) -> Void)?
    // MARK: - Monitor
    
    /// 停止按钮点击
    @IBAction func stopButtonClick() {
        monitorCompletion?(self, 100001)
    }
    
    /// 定时
    @IBAction func timingButtonClick(_ sender: UIButton) {
        monitorCompletion?(self, sender.tag)
    }
}

