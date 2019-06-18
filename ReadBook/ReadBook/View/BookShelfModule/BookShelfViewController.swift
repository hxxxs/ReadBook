//
//  BookShelfViewController.swift
//  ReadBook
//
//  Created by 123 on 2019/5/17.
//  Copyright © 2019 hxs. All rights reserved.
//  书架控制器

import UIKit

private let reuseIdentifier = "Cell"

class BookShelfViewController: UIViewController {

    /// 集合视图
    private lazy var collectionView: UICollectionView = {
        let fl = UICollectionViewFlowLayout()
        fl.itemSize = CGSize(width: wScreen / 2, height: 150)
        fl.minimumLineSpacing = 0
        fl.minimumInteritemSpacing = 0
        
        let v = UICollectionView(frame: view.bounds, collectionViewLayout: fl)
        v.dataSource = self
        v.delegate = self
        v.register(BookShelfCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        v.backgroundColor = UIColor.white
        v.showsVerticalScrollIndicator = false
        
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressGestureClick))
        v.addGestureRecognizer(gesture)
        return v
    }()
    
    /// 完成按钮
    private lazy var doneItem = UIBarButtonItem(title: "完成", style: .done, target: self, action: #selector(doneItemClick))
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        title = "书架"
       
        view.addSubview(collectionView)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addItemClick))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.rightBarButtonItem = nil
        collectionView.reloadData()
    }

}

// MARK: - Monitor

extension BookShelfViewController {
    
    /// 添加
    @objc private func addItemClick() {
        let vc = RBAlertController(title: "添加", message: nil, preferredStyle: .alert)
        vc.addTextField { (textField) in
            textField.placeholder = "请输入标题"
            textField.font = UIFont.systemFont(ofSize: 20)
        }
        vc.addTextField { (textField) in
            textField.placeholder = "请输入章节地址"
            textField.font = UIFont.systemFont(ofSize: 20)
            textField.keyboardType = .URL
        }
        vc.addTextField { (textField) in
            textField.placeholder = "请输入offset"
            textField.font = UIFont.systemFont(ofSize: 20)
            textField.keyboardType = .numberPad
        }
        vc.addTextField { (textField) in
            textField.placeholder = "请输入图片地址"
            textField.font = UIFont.systemFont(ofSize: 20)
            textField.keyboardType = .URL
        }
        vc.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { (_) in
        }))
        
        vc.addAction(UIAlertAction(title: "确定", style: .default, handler: {[weak self] (_) in
            guard let sself = self else { return }
           
            if let tf = vc.textFields?[1],
                let url = tf.text,
                let params = url.urlParameters,
                let book = BookInfoModel.deserialize(from: params) {
                book.title = vc.textFields?.first?.text ?? ""
                if let offset = vc.textFields?[2].text {
                    book.offset = Int(offset) ?? 0
                }
                book.picUrl = vc.textFields?[3].text ?? ""
                BookShelfModel.addRead(with: book)
                sself.collectionView.reloadData()
            }
        }))
        present(vc, animated: true, completion: nil)
    }
    
    /// 完成
    @objc private func doneItemClick() {
        navigationItem.rightBarButtonItem = nil
        collectionView.reloadData()
    }
    
    /// 长按手势
    @objc private func longPressGestureClick() {
        if navigationItem.rightBarButtonItem == nil {
            navigationItem.rightBarButtonItem = doneItem
            collectionView.reloadData()
        }
    }
}

// MARK: UICollectionViewDelegate

extension BookShelfViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = ChapterViewController()
        let model =  BookShelfModel.books[indexPath.row]
        BookShelfModel.currentRead(with: model)
        vc.viewModel = ReadViewModel(bookInfo: model)
        let cell: BookShelfCell = collectionView.cellForItem(at: indexPath) as! BookShelfCell // swiftlint:disable:this force_cast
        vc.speechViewModel = SpeechViewModel(with: cell.bookImage)
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: UICollectionViewDataSource

extension BookShelfViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return BookShelfModel.books.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? BookShelfCell
        cell?.model =  BookShelfModel.books[indexPath.row]
        cell?.showDeleteButton = navigationItem.rightBarButtonItem == nil
        cell?.deleteButtonCallBack = {[weak self] model in
            BookShelfModel.deleteRead(with: model)
            self?.collectionView.reloadData()
        }
        return cell!
    }

}
