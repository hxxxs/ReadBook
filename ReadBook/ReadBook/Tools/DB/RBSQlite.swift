//
//  RBSQlite.swift
//  ReadBook
//
//  Created by 123 on 2019/6/5.
//  Copyright © 2019 hxs. All rights reserved.
//

import Foundation
import SQLite

class RBSQlite: NSObject {
    
    static let shared = RBSQlite()
    
    let id = Expression<Int>("id")
    let book_id = Expression<String>("book_id")
    let offset = Expression<Int>("offset")
    let jsonString = Expression<String>("jsonString")
    let books = Table("books")
    let path = "books.sqlite3".appendDocumentDir
    
    override init() {
        super.init()
        
        guard let db = try? Connection(path) else { return }
        do {
            try db.run(books.create(block: { (t) in
                t.column(id, primaryKey: .autoincrement)
                t.column(book_id)
                t.column(offset)
                t.column(jsonString)
            }))
        } catch {
            print(error)
        }
    }
    
    func insert(id: String, offset: Int, jsonString: String) {
        do {
            let db = try Connection(path)
            
            if try db.run(books.insert(book_id <- id, self.offset <- offset, self.jsonString <- jsonString)) > 0 {
                debugPrint("数据插入成功")
            } else {
                debugPrint("数据插入失败")
            }
        } catch {
            debugPrint("数据插入失败")
        }
    }
    
    func prepare(id: String, offset: Int) -> String? {
        do {
            let db = try Connection(path)
            let query = books.filter(self.book_id == id).filter(self.offset == offset)
            let arr = try Array(db.prepare(query))
            if arr.count > 0 {
                debugPrint("本地数据获取成功")
                return arr[0][jsonString]
            }
            return nil
        } catch {
            return nil
        }
    }
}
