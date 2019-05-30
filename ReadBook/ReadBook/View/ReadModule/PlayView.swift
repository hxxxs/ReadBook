//
//  PlayView.swift
//  ReadBook
//
//  Created by 123 on 2019/5/30.
//  Copyright © 2019 hxs. All rights reserved.
//

import UIKit

class PlayView: UIView {
    
    var monitorCompletion: ((_ view: UIView, _ type: Int) -> ())?
    // MARK: - Monitor
    
    @IBAction func stopButtonClick() {
        monitorCompletion?(self, 100001)
    }
    
    @IBAction func timingButtonClick(_ sender: UIButton) {
        monitorCompletion?(self, sender.tag)
    }
}

