//
//  BooksAPI.swift
//  ReadBook
//
//  Created by 123 on 2019/6/11.
//  Copyright © 2019 hxs. All rights reserved.
//

enum BooksAPI {
    case chapter(gid: String,
        cid: String,
        url: String)
}

extension BooksAPI: TargetType {
    var baseURL: URL {
        return URL(string: "https://m.baidu.com")!
    }
    
    var path: String {
        switch self {
        case .chapter:
            return "/tcx"
        }
    }
    
    var method: Moya.Method {
        return .get
    }
    
    /// 单元测试用
    var sampleData: Data {
        return "".data(using: .utf8)!
    }
    
    var task: Task {
        switch self {
        case let .chapter(gid, cid, url):
            let params = ["appui": "alaxs",
                 "page": "api/chapterContent",
                 "gid": gid,
                 "cid": cid,
                 "url": url]
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case let .chapter(gid, cid, url):
            return ["Referer": "https://m.baidu.com/tcx?appui=alaxs&data={%22fromaction%22:%22search_zhongjianye67%22,%22query%22:%22%E4%B9%9D%E6%98%9F%E6%AF%92%E5%A5%B6%22}&page=detail&gid=\(gid)&cid=\(cid)&sign=55898a3991c7fef535266c1d583bbd17&ts=1566972196&url=\(url)",
                "X-Requested-With": "XMLHttpRequest"
            ]
        }
    }
}
