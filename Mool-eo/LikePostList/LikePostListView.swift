//
//  LikePostListView.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/11/24.
//

import UIKit
import SnapKit

class LikePostListView: BaseView {
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(LikePostTableViewCell.self, forCellReuseIdentifier: LikePostTableViewCell.identifier)
        tableView.register(LikePostWithoutImageTableViewCell.self, forCellReuseIdentifier: LikePostWithoutImageTableViewCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        return tableView
    }()
    
    let emptyView = EmptyView()
    
    override func configureHierarchy() {
        addSubview(tableView)
        addSubview(emptyView)
    }
    
    override func configureConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }
        
        emptyView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }
    }
}
