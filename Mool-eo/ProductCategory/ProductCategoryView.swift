//
//  ProductCategoryView.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/17/24.
//

import UIKit
import SnapKit

final class ProductCategoryView: BaseView {
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ProductCategoryTableViewCell.self, forCellReuseIdentifier: ProductCategoryTableViewCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension
        return tableView
    }()
    
    override func configureHierarchy() {
        addSubview(tableView)
    }
    
    override func configureConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
