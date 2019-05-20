//
//  ReadViewController.swift
//  ReadBook
//
//  Created by 123 on 2019/5/15.
//  Copyright © 2019 hxs. All rights reserved.
//

import UIKit
import SnapKit
import XSUtil

class ReadViewController: UIViewController {
    
    private lazy var textView: UITextView = {
        let v = UITextView()
        v.textColor = UIColor(hex: 0x546356)
        v.backgroundColor = UIColor.clear
        v.delegate = self
        v.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(textViewTap)))
        v.contentInset = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        return v
    }()
    private lazy var maskView: MaskView = {
        let v = MaskView(frame: .zero)
        v.isHidden = true
        v.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(maskViewTap)))
        v.monitorCompletion = {[weak self] type in
            guard let strongSelf = self else { return }
            switch type {
            case 100001: // 上一章
                strongSelf.textView.setContentOffset(CGPoint.zero, animated: false)
                strongSelf.loadData(offset: strongSelf.viewModel.bookInfo.offset - 1)
            case 100002: // 下一章
                strongSelf.textView.setContentOffset(CGPoint.zero, animated: false)
                strongSelf.loadData(offset: strongSelf.viewModel.bookInfo.offset + 1)
            case 100003:
                XSHUD.show(text: "程序员小哥哥在想解决办法")
            case 100004:
                if let model = strongSelf.chapterModel {
                    strongSelf.fontSize -= 1
                    strongSelf.chapterModel = model
                }
            case 100005:
                if let model = strongSelf.chapterModel {
                    strongSelf.fontSize += 1
                    strongSelf.chapterModel = model
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
    
    deinit {
        XSHUD.dismiss()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor(hex: 0xCDDFD1)
        view.addSubview(textView)
        textView.snp.makeConstraints { (make) in
            make.top.equalTo(topLayoutGuide.snp.bottom)
            make.left.right.bottom.equalToSuperview()
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
        textView.isUserInteractionEnabled = false
        viewModel.loadChapterInfo(offset: offset) {[weak self] (model) in
            self?.chapterModel = model
            self?.title = model.current.title
            self?.maskView.isHidden = true
            
            self?.maskView.chapterButtonEnable(previous: model.previous.offset > 0, next: model.next.offset > 0)
            self?.textView.isUserInteractionEnabled = true
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

// MARK: - UITextViewDelegate

extension ReadViewController: UITextViewDelegate {
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return false
    }
}
