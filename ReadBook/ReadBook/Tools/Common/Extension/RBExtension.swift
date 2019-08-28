//
//  RBExtension.swift
//  ReadBook
//
//  Created by 123 on 2019/6/5.
//  Copyright © 2019 hxs. All rights reserved.
//

import Foundation

extension String {
    
    /// 从String中截取出参数
    var urlParameters: [String: Any]? {
        // 判断是否有参数
        if !contains("?") {
            return nil
        }
        
        var params = [String: AnyObject]()
        // 截取参数
        let range = (self as NSString).range(of: "?")
        let paramsString = (self as NSString).substring(from: range.location + 1)
        
        // 判断参数是单个参数还是多个参数
        if paramsString.contains("&") {
            
            // 多个参数，分割参数
            let urlComponents = paramsString.components(separatedBy: "&")
            
            // 遍历参数
            for keyValuePair in urlComponents {
                // 生成Key/Value
                let pairComponents = keyValuePair.components(separatedBy: "=")
                let key = pairComponents.first
                let value = pairComponents.last?.replacingOccurrences(of: "%7C", with: "|").replacingOccurrences(of: "%3A", with: ":").replacingOccurrences(of: "%2F", with: "/")
                // 判断参数是否是数组
                if let key = key, let value = value {
                    // 已存在的值，生成数组
                    if let existValue = params[key] {
                        if var existValue = existValue as? [AnyObject] {
                            existValue.append(value as AnyObject)
                        } else {
                            params[key] = [existValue, value] as AnyObject
                        }
                    } else {
                        params[key] = value as AnyObject
                    }
                }
            }
        } else {
            // 单个参数
            let pairComponents = paramsString.components(separatedBy: "=")
            
            // 判断是否有值
            if pairComponents.count == 1 {
                return nil
            }
            let key = pairComponents.first
            let value = pairComponents.last
            if let key = key, let value = value {
                params[key] = value as AnyObject
            }
        }
        return params
    }
}
