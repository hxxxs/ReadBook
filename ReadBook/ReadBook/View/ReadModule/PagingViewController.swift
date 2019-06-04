//
//  PagingViewController.swift
//  Chapter
//
//  Created by 123 on 2019/6/3.
//  Copyright © 2019 hxs. All rights reserved.
//

import UIKit

class PagingViewController: UIViewController {
    
    var monitorCompletion: ((_ type: Int) -> ())?
    
    //  MARK: - Private
    
    private lazy var textView: UITextView = {
        let v = UITextView()
        v.backgroundColor = UIColor.clear
        v.isUserInteractionEnabled = false
        return v
    }()
    
    /// 上一页
    private lazy var pageUpButton = UIButton(target: self, action: #selector(pageUpButtonClick))
    
    /// 下一页
    private lazy var pageDownButton = UIButton(target: self, action: #selector(pageDownButtonClick))
    
    //  MARK: - override

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor(hex: 0xCDDFD1)
        view.addSubview(textView)
        
        view.addSubview(pageUpButton)
        view.addSubview(pageDownButton)
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(textViewTap)))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        textView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview().inset(15)
            make.top.bottom.equalToSuperview()
        }
        
        pageUpButton.snp.makeConstraints { (make) in
            make.left.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.25)
        }
        
        pageDownButton.snp.makeConstraints { (make) in
            make.right.top.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.25)
        }
    }
    
    //  MARK: -
    
    func speechContent(unread: String, read: String? = nil) {
        let paragraph = NSMutableParagraphStyle()
        paragraph.lineSpacing = 15
        
        let attr1 = [NSAttributedString.Key.paragraphStyle: paragraph,
                     NSAttributedString.Key.font: UIFont.systemFont(ofSize: SettingModel.textFontSize), NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1)]
        let attr2 = [NSAttributedString.Key.paragraphStyle: paragraph,
                     NSAttributedString.Key.font: UIFont.systemFont(ofSize: SettingModel.textFontSize),NSAttributedString.Key.foregroundColor: #colorLiteral(red: 0.3294117647, green: 0.3882352941, blue: 0.337254902, alpha: 1)]
        
        let attr = NSMutableAttributedString(string: read ?? "", attributes: attr1)
        attr.append(NSAttributedString(string: unread, attributes: attr2))
        textView.attributedText = attr
    }
}

// MARK: - Monitor

extension PagingViewController {
    
    @objc private func pageUpButtonClick() {
        monitorCompletion?(100001)
    }
    
    @objc private func pageDownButtonClick() {
        monitorCompletion?(100002)
    }
    
    @objc private func textViewTap() {
        monitorCompletion?(100003)
    }
}
