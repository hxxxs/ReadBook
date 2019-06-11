//
//  ReadViewModel.swift
//  ReadBook
//
//  Created by 123 on 2019/5/16.
//  Copyright © 2019 hxs. All rights reserved.
//  阅读视图模型

import Foundation
import Alamofire
import XSUtil
import SQLite

struct ReadViewModel {
    
    /// 书信息模型
    var bookInfo: BookInfoModel
    
    /// 加载章节信息
    ///
    /// - Parameters:
    ///   - offset: 章节编码
    ///   - completion: 完成结果
    func loadChapterInfo(offset: Int, completion: @escaping (ReadModel) -> Void) {
        
        if let jsonString = RBSQlite.shared.prepare(id: bookInfo.id, offset: offset) {
            if let model = ReadModel.deserialize(from: jsonString) {
                self.bookInfo.offset = model.current.offset
                BookShelfModel.changeCurrentReadOffset(with: self.bookInfo)
                completion(model)
            }
        } else {
            networkLoadChapterInfo(offset: offset, completion: completion)
        }
    }
    
    /// 网络加载章节信息
    ///
    /// - Parameters:
    ///   - offset: 章节编码
    ///   - completion: 完成结果
    func networkLoadChapterInfo(offset: Int, completion: @escaping (ReadModel) -> Void) {
        let params = ["v": "5",
                      "type": "1",
                      "id": bookInfo.id,
                      "md": bookInfo.md,
                      "cmd": bookInfo.cmd,
                      "offset": "\(offset)",
            "sgid": "",
            "encodeUrl": bookInfo.encodeUrl,
            "gf": "evryw-d1-pdetail-i"]
        
        let headers = ["Referer": "http://k.sogou.com/vrtc/detail?v=2&sid=00&uID=besbbUzD-KWbQAl5&sgid=null&gf=evryw-d1-pls-i&md=\(bookInfo.md)&id=\(bookInfo.id)&cmd=\(bookInfo.cmd)&url=\(bookInfo.encodeUrl)&nn=&finalChapter=true?",
            "Cookie": "page_mode=1; s_n_h=3163220789412855037%2610899536148534750089%26886%260%261553222102177%26gf%3Devryw-d1-pupdateBookmark-i|9787477184290606423%267249058444909006737%26226%260%261557898484496%26gf%3Devryw-d1-pupdateBookmark-i; font_size=24; YUEDUPID=sogouwap; usid=besbbUzD-KWbQAl5; JSESSIONID=aaaa-aNVv0kCL-SXI_1Qw; gpsloc=%E8%BE%BD%E5%AE%81%E7%9C%81%09%E6%B2%88%E9%98%B3%E5%B8%82; FREQUENCY=1553158078005_3; ld=vlllllllll2tLLgplllllV8bBt7lllllnhc12kllllwlllllRZlll5@@@@@@@@@@; SNUID=15170C182226AAC19F96FDAB230BD532; IPLOC=CN2101; front_screen_resolution=750*1334; CXID=6D524F39C4B9E952D361D2AA08CC7963; SUV=00B61B013B2E34365C934FB487137994; fromwww=1; wuid=AAFmSg1WJgAAAAqZEjzchwEAZAM=",
            "X-Requested-With": "XMLHttpRequest"]
        
        XSHUD.show(text: "正在加载中...", autoDismiss: false)
        
        Alamofire.request("http://k.sogou.com/novel/loadChapter", method: .get, parameters: params, headers: headers).responseJSON { (response) in
            guard let dic = response.result.value as? [String: Any],
                let data = dic["data"] as? [[String: Any]],
                let model = ReadModel.deserialize(from: data.first) else {
                    return
            }
            
            self.bookInfo.offset = model.current.offset
            RBSQlite.shared.insert(id: self.bookInfo.id, offset: model.current.offset, jsonString: model.toJSONString() ?? "")
            BookShelfModel.changeCurrentReadOffset(with: self.bookInfo)
            completion(model)
            XSHUD.dismiss()
        }
    }
}
