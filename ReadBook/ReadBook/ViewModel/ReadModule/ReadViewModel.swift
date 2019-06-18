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
            if let model = ReadModel(JSONString: jsonString) {
                self.bookInfo.offset = model.offset
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
                    let data = value["data"] as? [[String: Any]],
                    let json = data.first,
                    let model = ReadModel(JSON: json) {
                    self.bookInfo.offset = model.offset
                    RBSQlite.shared.insert(id: self.bookInfo.id, offset: model.offset, jsonString: model.toJSONString() ?? "")
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
