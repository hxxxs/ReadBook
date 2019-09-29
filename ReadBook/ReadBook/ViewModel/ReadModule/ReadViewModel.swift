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
    func loadChapterInfo(cid: String, url: String, completion: @escaping (ReadModel?, String?) -> Void) {
        
        if let jsonString = RBSQlite.shared.prepare(id: bookInfo.gid, cid: cid) {
            if let model = ReadModel(JSONString: jsonString) {
                self.bookInfo.cid = cid
                self.bookInfo.url = url
                BookShelfModel.changeCurrentReadOffset(with: self.bookInfo)
                completion(model, nil)
            }
        } else {
            networkLoadChapterInfo(cid: cid, url: url, completion: completion)
        }
    }
    
    /// 网络加载章节信息
    func networkLoadChapterInfo(cid: String, url: String, completion: @escaping (ReadModel?, String?) -> Void) {
        let target = BooksAPI.chapter(gid: bookInfo.gid, cid: cid, url: url)
        let provider = MoyaProvider<BooksAPI>(requestClosure: { (endpoint: Endpoint, done: MoyaProvider.RequestResultClosure) in
            do {
                var request = try endpoint.urlRequest()
                request.timeoutInterval = 30
                done(.success(request))
            } catch {
                done(.failure(MoyaError.underlying(error, nil)))
            }
        })
        
        provider.rx
            .request(target)
            .filterSuccessfulStatusCodes()
            .mapJSON()
            .subscribe(onSuccess: { (result) in
                if let value = result as? [String: Any],
                    let data = value["data"] as? [String: Any],
                    let model = ReadModel(JSON: data) {
                    self.bookInfo.cid = cid
                    self.bookInfo.url = url
                    RBSQlite.shared.insert(id: self.bookInfo.gid, cid: cid, jsonString: model.toJSONString() ?? "")
                    BookShelfModel.changeCurrentReadOffset(with: self.bookInfo)
                    completion(model, nil)
                } else {
                    completion(nil, "数据解析失败")
                }
            }, onError: { (error) in
                completion(nil, error.localizedDescription)
            })
    }
}
