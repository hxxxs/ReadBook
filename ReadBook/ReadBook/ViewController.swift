//
//  ViewController.swift
//  ReadBook
//
//  Created by 123 on 2019/5/15.
//  Copyright © 2019 hxs. All rights reserved.
//

import UIKit
import HandyJSON

class ViewController: UIViewController {
    
    private lazy var tableView: UITableView = {
        let tv = UITableView(frame: view.bounds, style: .plain)
        tv.delegate = self
        tv.dataSource = self
        tv.rowHeight = 50
        tv.separatorStyle = .none
        return tv
    }()
    
    private var dataSource = [BookInfoModel]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "书架"
        view.addSubview(tableView)
        if let path = Bundle.main.url(forResource: "Books.json", withExtension: nil),
            let data = try? Data(contentsOf: path),
            let arrays = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: String]] {
            for dict in arrays! {
                if let info = BookInfoModel.deserialize(from: dict) {
                    info.offset = UserDefaults.standard.integer(forKey: info.title)
                    dataSource.append(info)
                }
            }
            tableView.reloadData()
        }
    }
    
}

extension ViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let vc = ReadViewController()
        vc.viewModel = ReadViewModel(bookInfo: dataSource[indexPath.row])
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = "reuseIdentifier"
        var cell = tableView.dequeueReusableCell(withIdentifier: identifier)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: identifier)
        }
        cell?.textLabel?.text = dataSource[indexPath.row].title
        return cell!
    }
}

