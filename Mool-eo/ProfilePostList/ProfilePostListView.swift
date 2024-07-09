//
//  ProfilePostListView.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/16/24.
//

import UIKit
import SnapKit

class ProfilePostListView: BaseView {
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(LikePostTableViewCell.self, forCellReuseIdentifier: LikePostTableViewCell.identifier)
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
