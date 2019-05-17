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

    private var dataSource = [BookInfoModel]()
    private lazy var collectionView: UICollectionView = {
        let fl = UICollectionViewFlowLayout()
        fl.itemSize = CGSize(width: wScreen / 2, height: 150)
        fl.minimumLineSpacing = 10
        fl.minimumInteritemSpacing = 0
        
        let v = UICollectionView(frame: view.bounds, collectionViewLayout: fl)
        v.dataSource = self
        v.delegate = self
        v.isPagingEnabled = true
        v.bounces = false
        v.register(BookShelfCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        v.backgroundColor = UIColor.white
        v.showsVerticalScrollIndicator = false
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        title = "书架"
       
        view.addSubview(collectionView)
        
        
        if let path = Bundle.main.url(forResource: "Books.json", withExtension: nil),
            let data = try? Data(contentsOf: path),
            let arrays = try? JSONSerialization.jsonObject(with: data, options: []) as? [[String: String]] {
            for dict in arrays! {
                if let info = BookInfoModel.deserialize(from: dict) {
                    info.offset = UserDefaults.standard.integer(forKey: info.title)
                    dataSource.append(info)
                }
            }
            collectionView.reloadData()
        }
    }

    
    

}

// MARK: UICollectionViewDelegate

extension BookShelfViewController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = ReadViewController()
        vc.viewModel = ReadViewModel(bookInfo: dataSource[indexPath.row])
        navigationController?.pushViewController(vc, animated: true)
    }
}

// MARK: UICollectionViewDataSource

extension BookShelfViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? BookShelfCell
        cell?.model = dataSource[indexPath.row]
        return cell!
    }

}
