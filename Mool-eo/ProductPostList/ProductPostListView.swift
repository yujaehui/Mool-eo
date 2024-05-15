//
//  ProductPostListView.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/10/24.
//

import UIKit
import SnapKit

class ProductPostListView: BaseView {
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ProdcutPostListTableViewCell.self, forCellReuseIdentifier: ProdcutPostListTableViewCell.identifier)
        return tableView
    }()
    
    override func configureHierarchy() {
        addSubview(tableView)
    }
    
    override func configureConstraints() {
        tableView.snp.makeConstraints { make in
            make.verticalEdges.equalTo(safeAreaLayoutGuide)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide)
        }
    }
    
//    private func configureCollectionViewLayout() -> UICollectionViewLayout {
//        let layout = UICollectionViewFlowLayout()
//        let spacing: CGFloat = 10
//        let cellWidth = UIScreen.main.bounds.width - (spacing * 3)
//        layout.itemSize = CGSize(width: cellWidth / 2, height: cellWidth / 2 + 55)
//        layout.sectionInset = UIEdgeInsets(top: 0, left: spacing, bottom: 0, right: spacing)
//        layout.minimumInteritemSpacing = spacing
//        return layout
//    }
}
