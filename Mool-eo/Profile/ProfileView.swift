//
//  ProfileView.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/17/24.
//

import UIKit
import SnapKit

class ProfileView: BaseView {
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ProfileInfoTableViewCell.self, forCellReuseIdentifier: ProfileInfoTableViewCell.identifier)
        tableView.register(ProfileProdcutTableViewCell.self, forCellReuseIdentifier: ProfileProdcutTableViewCell.identifier)
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
