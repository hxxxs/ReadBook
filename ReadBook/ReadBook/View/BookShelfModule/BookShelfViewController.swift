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
        fl.itemSize = CGSize(width: wScreen / 3, height: 150)
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
