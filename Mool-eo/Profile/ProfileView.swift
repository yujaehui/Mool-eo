//
//  ProfileView.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/17/24.
//

import UIKit
import SnapKit

class ProfileView: BaseView {
    
    // Navigation
    let withdrawButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.title = "탈퇴"
        return button
    }()
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ProfileInfoTableViewCell.self, forCellReuseIdentifier: ProfileInfoTableViewCell.identifier)
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
