//
//  LikePostListView.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/11/24.
//

import UIKit
import SnapKit

final class LikePostListView: BaseView {
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(LikePostTableViewCell.self, forCellReuseIdentifier: LikePostTableViewCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension
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
