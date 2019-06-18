//
//  RBNetwork.swift
//  ReadBook
//
//  Created by 123 on 2019/6/11.
//  Copyright © 2019 hxs. All rights reserved.
//

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
        provider.rx
            .request(target)
            .filterSuccessfulStatusCodes()
            .mapJSON()
            .subscribe(onSuccess: { (result) in
                if let value = result as? [String: Any] {
                    successClosure(value)
                } else {
                    failClosure("数据解析失败")
                }
            }, onError: { (error) in
                failClosure(error.localizedDescription)
            })
    }
}
