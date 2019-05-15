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
        v.textColor = UIColor.darkGray
        v.isEditable = false
        v.backgroundColor = UIColor(hex: 0xC7EDCC)
        v.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(textViewTap)))
        return v
    }()
    private lazy var previousButton: UIButton = {
        let btn = UIButton(title: "上一页", titleColor: UIColor(hex: 0xfe3650), font: UIFont.systemFont(ofSize: 20), target: self, action: #selector(previousButtonClick), type: .custom)
        btn.backgroundColor = UIColor.white
        return btn
    }()
    private lazy var nextButton: UIButton = {
        let btn = UIButton(title: "下一页", titleColor: UIColor(hex: 0xfe3650), font: UIFont.systemFont(ofSize: 20), target: self, action: #selector(nextButtonClick), type: .custom)
        btn.setTitle("没有新章节", for: .disabled)
        btn.setTitleColor(UIColor.darkGray, for: .disabled)
        btn.backgroundColor = UIColor.white
        return btn
    }()
    private lazy var maskView: UIView = {
        let v = UIView(frame: view.bounds)
        v.backgroundColor = UIColor(white: 0.3, alpha: 0.3)
        v.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(maskViewTap)))
        v.isHidden = true
        return v
    }()
    
    var info: BookInfoModel!
    var offset = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.white
        view.addSubview(textView)
        textView.snp.makeConstraints { (make) in
            make.top.equalTo(topLayoutGuide.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        
        view.addSubview(maskView)
        maskView.addSubview(previousButton)
        maskView.addSubview(nextButton)
        
        previousButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(150)
        }
        
        nextButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(150)
        }
        
        loadData(offset: offset)
    }

}

// MARK: - Net

extension ReadViewController {
    
    private func loadData(offset: Int) {
        let params = ["v": "5",
                      "type": "1",
                      "id": info.id,
                      "md": info.md,
                      "cmd": info.cmd,
                      "offset": "\(offset)",
                      "sgid": "",
                      "encodeUrl": info.encodeUrl,
                      "gf": "evryw-d1-pdetail-i"]
        
        let headers = ["Referer": "http://k.sogou.com/vrtc/detail?v=2&sid=00&uID=besbbUzD-KWbQAl5&sgid=null&gf=evryw-d1-pls-i&md=\(info.md)&id=\(info.id)&cmd=\(info.cmd)&url=\(info.encodeUrl)&nn=&finalChapter=true?",
                       "Cookie": "page_mode=1; s_n_h=3163220789412855037%2610899536148534750089%26886%260%261553222102177%26gf%3Devryw-d1-pupdateBookmark-i|9787477184290606423%267249058444909006737%26226%260%261557898484496%26gf%3Devryw-d1-pupdateBookmark-i; font_size=24; YUEDUPID=sogouwap; usid=besbbUzD-KWbQAl5; JSESSIONID=aaaa-aNVv0kCL-SXI_1Qw; gpsloc=%E8%BE%BD%E5%AE%81%E7%9C%81%09%E6%B2%88%E9%98%B3%E5%B8%82; FREQUENCY=1553158078005_3; ld=vlllllllll2tLLgplllllV8bBt7lllllnhc12kllllwlllllRZlll5@@@@@@@@@@; SNUID=15170C182226AAC19F96FDAB230BD532; IPLOC=CN2101; front_screen_resolution=750*1334; CXID=6D524F39C4B9E952D361D2AA08CC7963; SUV=00B61B013B2E34365C934FB487137994; fromwww=1; wuid=AAFmSg1WJgAAAAqZEjzchwEAZAM=",
                       "X-Requested-With": "XMLHttpRequest"]
       
        Alamofire.request("http://k.sogou.com/novel/loadChapter", method: .get, parameters: params, headers: headers).responseJSON { (response) in
            guard let dic = response.result.value as? [String: Any],
                let data = dic["data"] as? [[String: Any]],
                let model = ReadModel.deserialize(from: data.first) else {
                return
            }
            
            let paragraph = NSMutableParagraphStyle()
            paragraph.lineSpacing = 5
            self.textView.attributedText = NSAttributedString(string: model.chapter.content.replacingOccurrences(of: "<br/>", with: "\n"), attributes: [NSAttributedString.Key.paragraphStyle: paragraph,
                                                                                                                                                        NSAttributedString.Key.font: UIFont.systemFont(ofSize: 24)])
            self.title = model.current.title
            self.maskView.isHidden = true
            
            UserDefaults.standard.set(self.offset, forKey: self.info.title)
            UserDefaults.standard.synchronize()
            self.nextButton.isEnabled = model.next.offset > 0
            self.previousButton.isHidden = model.previous.offset < 0
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
    
    @objc func previousButtonClick() {
        offset -= 1
        loadData(offset: offset)
    }
    
    @objc func nextButtonClick() {
        offset += 1
        loadData(offset: offset)
    }
}
