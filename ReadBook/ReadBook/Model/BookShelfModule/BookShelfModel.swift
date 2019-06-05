//
//  BookShelfModel.swift
//  ReadBook
//
//  Created by 123 on 2019/5/20.
//  Copyright © 2019 hxs. All rights reserved.
//  书架模型

import Foundation

private let BooksPath = "Books.json"

struct BookShelfModel {
    static var shared: BookShelfModel = {
        var books = [BookInfoModel]()
        let jsonPath = BooksPath.appendDocumentDir
        var data = NSData(contentsOfFile: jsonPath)
        
        if data == nil {
            let path = Bundle.main.url(forResource: BooksPath, withExtension: nil)
            data = NSData(contentsOf: path!)
        }
        
        if let arrays = try? JSONSerialization.jsonObject(with: data! as Data, options: []) as? [[String: Any]] {
            
            for dict in arrays {
                if let info = BookInfoModel.deserialize(from: dict) {
                    books.append(info)
                }
            }
        }
        
        let model = BookShelfModel(books: books)
        return model
    }()
    
    static var books: [BookInfoModel] {
        return shared.books
    }
    
    private var books: [BookInfoModel]
    
    static func addRead(with model: BookInfoModel) {
        shared.books.append(model)
        save()
    }
    
    static func deleteRead(with model: BookInfoModel) {
        shared.books = shared.books.filter { (book) -> Bool in
            return book.title != model.title
        }
        save()
    }
    
    static func currentRead(with model: BookInfoModel) {
        shared.books = shared.books.filter { (book) -> Bool in
            return book.title != model.title
        }
        shared.books.insert(model, at: 0)
        save()
    }
    
    static func changeCurrentReadOffset(with model: BookInfoModel) {
        shared.books = shared.books.map { (book) in
            if book.title == model.title {
                book.offset = model.offset
            }
            return book
        }
        save()
    }
    
    static private func save() {
        if let data = try? JSONSerialization.data(withJSONObject: shared.books.toJSON(), options: .prettyPrinted) {
            let jsonPath = BooksPath.appendDocumentDir
            (data as NSData).write(toFile: jsonPath, atomically: true)
        }
    }
}
