//
//  BookShelfViewController.swift
//  ReadBook
//
//  Created by 123 on 2019/5/17.
//  Copyright © 2019 hxs. All rights reserved.
//

import UIKit
import XSExtension

private let reuseIdentifier = "Cell"

class BookShelfViewController: UIViewController {

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
    
    private lazy var doneItem = UIBarButtonItem(title: "完成", style: .done, target: self, action: #selector(doneItemClick))
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        title = "书架"
       
        view.addSubview(collectionView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationItem.rightBarButtonItem = nil
        collectionView.reloadData()
    }

}

// MARK: - Monitor

extension BookShelfViewController {
    
    @objc func doneItemClick() {
        navigationItem.rightBarButtonItem = nil
        collectionView.reloadData()
    }
    
    @objc func longPressGestureClick() {
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
        let cell: BookShelfCell = collectionView.cellForItem(at: indexPath) as! BookShelfCell
        vc.bookImage = cell.bookImage
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
