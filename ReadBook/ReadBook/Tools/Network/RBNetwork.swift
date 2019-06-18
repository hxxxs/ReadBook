//
//  RBNetwork.swift
//  ReadBook
//
//  Created by 123 on 2019/6/11.
//  Copyright © 2019 hxs. All rights reserved.
//

import XSUtil
import Moya

class RBNetwork {
    static let shared = RBNetwork()
    
    private init() {}
    
    private let requestClose = { (endpoint: Endpoint, done: MoyaProvider.RequestResultClosure) in
        do {
            var request = try endpoint.urlRequest()
            request.timeoutInterval = 30
            done(.success(request))
        } catch {
            done(.failure(MoyaError.underlying(error, nil)))
        }
    }
    
    func requestDataTargetJSON<T: TargetType>(target: T, successClosure: @escaping ([String: Any]) -> Void, failClosure: @escaping (String) -> Void) {
        let provider = MoyaProvider<T>(requestClosure: requestClose)
        provider.request(target) { (result) in
            switch result {
            case let .success(value):
                if let result = try? value.mapJSON() as? [String: Any] {
                    successClosure(result)
                } else {
                    failClosure("数据解析失败")
                }
            case let .failure(error):
                failClosure(error.errorDescription ?? "")
            }
        }
    }
}
