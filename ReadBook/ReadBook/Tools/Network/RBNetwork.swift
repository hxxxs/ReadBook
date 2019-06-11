//
//  RBNetwork.swift
//  ReadBook
//
//  Created by 123 on 2019/6/11.
//  Copyright © 2019 hxs. All rights reserved.
//

import XSUtil
import Moya

/// 成功
typealias SuccessJSONClosure = (_ result: [String: Any]) -> Void
/// 失败
typealias FailClosure = (_ errorMsg: String?) -> Void

class RBNetwork {
    static let shared = RBNetwork()
    
    private init() {}
    
    func requestDataTargetJSON<T: TargetType>(target: T, successClosure: @escaping SuccessJSONClosure, failClosure: @escaping FailClosure) {
        
        XSHUD.show(text: "正在加载中...", autoDismiss: false)
        let provider = MoyaProvider<T>()
        provider.request(target) { (result) in
            switch result {
            case let .success(value):
                if let result = try? value.mapJSON() as? [String: Any] {
                    successClosure(result)
                } else {
                    failClosure("数据解析失败")
                }
            case let .failure(error):
                failClosure(error.errorDescription)
            }
            XSHUD.dismiss()
        }
    }
}
