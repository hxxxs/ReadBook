//
//  BooksAPI.swift
//  ReadBook
//
//  Created by 123 on 2019/6/11.
//  Copyright © 2019 hxs. All rights reserved.
//

import Moya

enum BooksAPI {
    case chapter(offset: Int,
        id: String,
        md: String,
        cmd: String,
        encodeUrl: String)
}

extension BooksAPI: TargetType {
    var baseURL: URL {
        return URL(string: "http://k.sogou.com")!
    }
    
    var path: String {
        switch self {
        case .chapter:
            return "/novel/loadChapter"
        }
    }
    
    var method: Method {
        return .get
    }
    
    /// 单元测试用
    var sampleData: Data {
        return "".data(using: .utf8)!
    }
    
    var task: Task {
        switch self {
        case let .chapter(offset, id, md, cmd, encodeUrl):
            let params = ["v": "5",
                          "type": "1",
                          "id": id,
                          "md": md,
                          "cmd": cmd,
                          "offset": "\(offset)",
                "sgid": "",
                "encodeUrl": encodeUrl,
                "gf": "evryw-d1-pdetail-i"]
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .chapter(_, let id, let md, let cmd, let encodeUrl):
            return ["Referer": "http://k.sogou.com/vrtc/detail?v=2&sid=00&uID=besbbUzD-KWbQAl5&sgid=null&gf=evryw-d1-pls-i&md=\(md)&id=\(id)&cmd=\(cmd)&url=\(encodeUrl)&nn=&finalChapter=true?",
                "Cookie": "page_mode=1; s_n_h=3163220789412855037%2610899536148534750089%26886%260%261553222102177%26gf%3Devryw-d1-pupdateBookmark-i|9787477184290606423%267249058444909006737%26226%260%261557898484496%26gf%3Devryw-d1-pupdateBookmark-i; font_size=24; YUEDUPID=sogouwap; usid=besbbUzD-KWbQAl5; JSESSIONID=aaaa-aNVv0kCL-SXI_1Qw; gpsloc=%E8%BE%BD%E5%AE%81%E7%9C%81%09%E6%B2%88%E9%98%B3%E5%B8%82; FREQUENCY=1553158078005_3; ld=vlllllllll2tLLgplllllV8bBt7lllllnhc12kllllwlllllRZlll5@@@@@@@@@@; SNUID=15170C182226AAC19F96FDAB230BD532; IPLOC=CN2101; front_screen_resolution=750*1334; CXID=6D524F39C4B9E952D361D2AA08CC7963; SUV=00B61B013B2E34365C934FB487137994; fromwww=1; wuid=AAFmSg1WJgAAAAqZEjzchwEAZAM=",
                "X-Requested-With": "XMLHttpRequest"
            ]
        }
    }
    
}

