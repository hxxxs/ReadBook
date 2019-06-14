//
//  RBAlertController.swift
//  ReadBook
//
//  Created by 123 on 2019/6/14.
//  Copyright © 2019 hxs. All rights reserved.
//

import UIKit

class RBAlertController: UIAlertController {

    override func viewDidLoad() {
        super.viewDidLoad()
        if let tfs = textFields {
            for tf in tfs {
                tf.superview?.superview?.backgroundColor = .white
            }
        }
    }
}
