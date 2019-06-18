//
//  ReadViewModel.swift
//  ReadBook
//
//  Created by 123 on 2019/5/16.
//  Copyright © 2019 hxs. All rights reserved.
//  阅读视图模型

import Foundation

struct ReadViewModel {
    
    /// 书信息模型
    var bookInfo: BookInfoModel
    
    /// 加载章节信息
    ///
    /// - Parameters:
    ///   - offset: 章节编码
    ///   - completion: 完成结果
    func loadChapterInfo(offset: Int, completion: @escaping (ReadModel?, String?) -> Void) {
        
        if let jsonString = RBSQlite.shared.prepare(id: bookInfo.id, offset: offset) {
            if let model = ReadModel.deserialize(from: jsonString) {
                self.bookInfo.offset = model.current.offset
                BookShelfModel.changeCurrentReadOffset(with: self.bookInfo)
                completion(model, nil)
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
    func networkLoadChapterInfo(offset: Int, completion: @escaping (ReadModel?, String?) -> Void) {
        let target = BooksAPI.chapter(offset: offset, id: bookInfo.id, md: bookInfo.md, cmd: bookInfo.cmd, encodeUrl: bookInfo.encodeUrl)
        RBNetwork.shared.requestDataTargetJSON(target: target, successClosure: { (result) in
            guard let data = result["data"] as? [[String: Any]],
                let model = ReadModel.deserialize(from: data.first) else {
                    return
            }
            
            self.bookInfo.offset = model.current.offset
            RBSQlite.shared.insert(id: self.bookInfo.id, offset: model.current.offset, jsonString: model.toJSONString() ?? "")
            BookShelfModel.changeCurrentReadOffset(with: self.bookInfo)
            completion(model, nil)
        }) { (text) in
            completion(nil, text)
        }
    }
}
