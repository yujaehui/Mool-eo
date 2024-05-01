//
//  ScrapPostListView.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/1/24.
//

import UIKit
import SnapKit

class ScrapPostListView: BaseView {
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(PostListTableViewCell.self, forCellReuseIdentifier: PostListTableViewCell.identifier)
        tableView.register(PostListWithoutImageTableViewCell.self, forCellReuseIdentifier: PostListWithoutImageTableViewCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension
        return tableView
    }()
    
    override func configureHierarchy() {
        addSubview(tableView)
    }
    
    override func configureConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }
    }
}
