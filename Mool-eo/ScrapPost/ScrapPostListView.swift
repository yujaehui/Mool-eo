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
        tableView.register(ProfileMyPostTableViewCell.self, forCellReuseIdentifier: ProfileMyPostTableViewCell.identifier)
        tableView.register(ProfileMyPostWithoutImageTableViewCell.self, forCellReuseIdentifier: ProfileMyPostWithoutImageTableViewCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
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
