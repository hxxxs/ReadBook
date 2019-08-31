//
//  AddBookViewController.swift
//  ReadBook
//
//  Created by hxs on 2019/8/31.
//  Copyright © 2019 hxs. All rights reserved.
//

import UIKit

class AddBookViewController: UITableViewController {
    
    @IBOutlet weak var bookNameTF: UITextField!
    @IBOutlet weak var bookImageTF: UITextField!
    @IBOutlet weak var chapterURLTF: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    @IBAction func saveBook(_ sender: UIBarButtonItem) {
        
        if let url = chapterURLTF.text,
            let params = url.urlParameters,
            let book = BookInfoModel(JSON: params) {
            book.title = bookNameTF.text ?? ""
            book.picUrl = bookImageTF.text ?? ""
            BookShelfModel.addRead(with: book)
            navigationController?.popViewController(animated: true)
        }
    }
    
    //  MARK: - UITableViewDelegate
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
}
