//
//  Common.swift
//  ReadBook
//
//  Created by 123 on 2019/5/15.
//  Copyright © 2019 hxs. All rights reserved.
//

import Foundation

/// 字典 -> 模型
///
/// - Parameters:
///   - type: 类型
///   - data: 字典数据
/// - Returns: 模型结果
/// - Throws: 错误处理
func JSONModel<T>(_ type: T.Type, withKeyValues data:[String:Any]) throws -> T where T: Decodable {
    let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
    let model = try JSONDecoder().decode(type, from: jsonData)
    return model
}

/// 字典数组 -> 模型数组
///
/// - Parameters:
///   - type: 类型
///   - datas: 字典组数
/// - Returns: 模型数组结果
/// - Throws: 错误处理
func JSONModels<T>(_ type: T.Type, withKeyValuesArray datas: [[String:Any]]) throws -> [T]  where T: Decodable {
    var temp: [T] = []
    for data in datas {
        let model = try JSONModel(type, withKeyValues: data)
        temp.append(model)
    }
    return temp
}
