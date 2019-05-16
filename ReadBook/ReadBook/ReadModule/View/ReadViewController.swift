//
//  ReadViewController.swift
//  ReadBook
//
//  Created by 123 on 2019/5/15.
//  Copyright © 2019 hxs. All rights reserved.
//

import UIKit
import Alamofire
import XSExtension
import HandyJSON
import SnapKit

class ReadViewController: UIViewController {
    
    private lazy var textView: UITextView = {
        let v = UITextView()
        v.textColor = UIColor(hex: 0x6C7B6E)
        v.isEditable = false
        v.backgroundColor = UIColor.clear
        v.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(textViewTap)))
        v.showsVerticalScrollIndicator = false
        return v
    }()
    private lazy var maskView: MaskView = {
        let v = MaskView(frame: .zero)
        v.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(maskViewTap)))
        v.monitorCompletion = { type in
            switch type {
            case 100001: // 上一章
                self.textView.setContentOffset(CGPoint.zero, animated: false)
                self.loadData(offset: self.viewModel.bookInfo.offset - 1)
            case 100002: // 下一章
                self.textView.setContentOffset(CGPoint.zero, animated: false)
                self.loadData(offset: self.viewModel.bookInfo.offset + 1)
            case 100003: break
            case 100004:
                if let model = self.chapterModel {
                    self.fontSize -= 1
                    self.chapterModel = model
                }
            case 100005:
                if let model = self.chapterModel {
                    self.fontSize += 1
                    self.chapterModel = model
                }
            default:
                break
            }
        }
        return v
    }()
    
    private var chapterModel: ReadModel? {
        didSet {
            guard let model = chapterModel else { return }
            let paragraph = NSMutableParagraphStyle()
            paragraph.lineSpacing = 15
            self.textView.attributedText = NSAttributedString(string: model.chapter.content.replacingOccurrences(of: "<br/>", with: "\n"), attributes: [NSAttributedString.Key.paragraphStyle: paragraph,
                                                                                                                                                        NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize)])
        }
    }
    
    private var fontSize = SettingModel.textFontSize {
        didSet {
            UserDefaults.standard.set(fontSize, forKey: kTextFontKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    var viewModel: ReadViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(hex: 0xCDDFD1)
        view.addSubview(textView)
        textView.snp.makeConstraints { (make) in
            make.top.equalTo(topLayoutGuide.snp.bottom)
            make.left.right.bottom.equalToSuperview().inset(10)
        }
        
        view.addSubview(maskView)
        maskView.snp.makeConstraints { (make) in
            make.left.top.right.equalToSuperview()
            make.bottom.equalTo(bottomLayoutGuide.snp.top)
        }
        
        loadData(offset: viewModel.bookInfo.offset)
    }

}

// MARK: - Net

extension ReadViewController {
    
    func loadData(offset: Int) {
        viewModel.loadChapterInfo(offset: offset) { (model) in
            self.chapterModel = model
            self.title = model.current.title
            self.maskView.isHidden = true
            
            self.maskView.chapterButtonEnable(previous: model.previous.offset > 0, next: model.next.offset > 0)
        }
    }
}

// MARK: - Monitor

extension ReadViewController {
    
    @objc func maskViewTap() {
        maskView.isHidden = true
    }
    
    @objc func textViewTap() {
        maskView.isHidden = false
    }

}
