//
//  ProductPostListView.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/10/24.
//

import UIKit
import SnapKit

class ProductPostListView: BaseView {
    
    lazy var collectionViewLayout = {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, environment) -> NSCollectionLayoutSection? in
            return ProductCategorySection().layoutSection()
        }
        return layout
    }()
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.register(ProductCategoryCollectionViewCell.self, forCellWithReuseIdentifier: ProductCategoryCollectionViewCell.identifier)
        return collectionView
    }()
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ProdcutPostListTableViewCell.self, forCellReuseIdentifier: ProdcutPostListTableViewCell.identifier)
        return tableView
    }()
    
    let postWriteButton: UIButton = {
        let button = UIButton()
        button.configuration = .postAdd("상품 등록")
        return button
    }()
    
    override func configureHierarchy() {
        addSubview(collectionView)
        addSubview(tableView)
        addSubview(postWriteButton)
    }
    
    override func configureConstraints() {
        collectionView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(safeAreaLayoutGuide)
            make.height.equalTo(50)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom)
            make.horizontalEdges.bottom.equalTo(safeAreaLayoutGuide)
        }
        
        postWriteButton.snp.makeConstraints { make in
            make.bottom.equalTo(safeAreaLayoutGuide).inset(20)
            make.trailing.equalTo(safeAreaLayoutGuide).inset(20)
        }
    }
}
