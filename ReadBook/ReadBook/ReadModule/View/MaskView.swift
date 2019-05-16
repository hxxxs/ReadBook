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
    
    //  MARK: -
    
    private lazy var previousButton: UIButton = {
        let btn = UIButton(title: "上一章", titleColor: UIColor.darkGray, font: UIFont.systemFont(ofSize: 15), target: self, action: #selector(buttonsClick), type: .custom)
        btn.tag = 100001
        return btn
    }()
    
    private lazy var nextButton: UIButton = {
        let btn = UIButton(title: "下一章", titleColor: UIColor.darkGray, font: UIFont.systemFont(ofSize: 15), target: self, action: #selector(buttonsClick), type: .custom)
        btn.setTitle("没有新章节", for: .disabled)
        btn.tag = 100002
        return btn
    }()
    
    private lazy var catalogButton: UIButton = {
        let attr = NSMutableAttributedString(attributedString: NSAttributedString(string: "\u{e601}", attributes: [NSAttributedString.Key.font : UIFont(name: "iconFont", size: 40)!]))
        attr.append(NSAttributedString(string: "\n\n", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 5)]))
        attr.append(NSAttributedString(string: "目录", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)]))
        let btn = UIButton(titleColor: UIColor.darkGray, titleAttr: attr, font: UIFont(name: "iconFont", size: 15)!, textAlignment: .center,  numberOfLines: 0, target: self, action: #selector(buttonsClick), type: .custom)
        btn.tag = 100003
        return btn
    }()
    
    private lazy var reduceFontButton: UIButton = {
        let attr = NSMutableAttributedString(attributedString: NSAttributedString(string: "\u{e60e}", attributes: [NSAttributedString.Key.font : UIFont(name: "iconFont", size: 40)!]))
        attr.append(NSAttributedString(string: "\n\n", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 5)]))
        attr.append(NSAttributedString(string: "字体", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)]))
        let btn = UIButton(titleColor: UIColor.darkGray, titleAttr: attr, font: UIFont(name: "iconFont", size: 15)!, textAlignment: .center,  numberOfLines: 0, target: self, action: #selector(buttonsClick), type: .custom)
        btn.tag = 100004
        return btn
    }()
    
    private lazy var addFontButton: UIButton = {
        let attr = NSMutableAttributedString(attributedString: NSAttributedString(string: "\u{e60f}", attributes: [NSAttributedString.Key.font : UIFont(name: "iconFont", size: 40)!]))
        attr.append(NSAttributedString(string: "\n\n", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 5)]))
        attr.append(NSAttributedString(string: "字体", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15)]))
        let btn = UIButton(titleColor: UIColor.darkGray, titleAttr: attr, font: UIFont(name: "iconFont", size: 15)!, textAlignment: .center,  numberOfLines: 0, target: self, action: #selector(buttonsClick), type: .custom)
        btn.tag = 100005
        return btn
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        configUI()
    }
    
    func chapterButtonEnable(previous: Bool, next: Bool) {
        previousButton.isEnabled = previous
        nextButton.isEnabled = next
    }
    
}

// MARK: - Monitor

extension MaskView {
    
    @objc private func buttonsClick(button: UIButton) {
        monitorCompletion?(button.tag)
    }
}

// MARK: - UI

extension MaskView {
    
    private func configUI() {
        backgroundColor = UIColor.clear
        
        let v = UIView()
        v.backgroundColor = UIColor(white: 1, alpha: 0.9)
        addSubview(v)
        
        v.snp.makeConstraints { (make) in
            make.bottom.left.right.equalToSuperview()
            make.height.equalTo(120)
        }
        
        let chapterSV = UIStackView(arrangedSubviews: [previousButton, nextButton])
        chapterSV.distribution = .fillEqually
        v.addSubview(chapterSV)
        
        chapterSV.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(40)
        }
        
        let line1 = UIView()
        line1.backgroundColor = UIColor.darkGray
        addSubview(line1)
        
        line1.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.equalTo(0.5)
            make.height.top.equalTo(chapterSV)
        }
        
        let line2 = UIView()
        line2.backgroundColor = UIColor.darkGray
        addSubview(line2)
        
        line2.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(0.5)
            make.top.equalTo(chapterSV.snp.bottom)
        }
        
        let setSV = UIStackView(arrangedSubviews: [catalogButton, reduceFontButton, addFontButton])
        setSV.distribution = .fillEqually
        addSubview(setSV)
        
        setSV.snp.makeConstraints { (make) in
            make.left.bottom.right.equalToSuperview()
            make.top.equalTo(line2.snp.bottom)
        }
    }
}
