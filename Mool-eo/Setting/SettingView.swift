//
//  SettingView.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/12/24.
//

import UIKit
import SnapKit

final class SettingView: BaseView {
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(SettingInfoTableViewCell.self, forCellReuseIdentifier: SettingInfoTableViewCell.identifier)
        tableView.register(SettingManagementTableViewCell.self, forCellReuseIdentifier: SettingManagementTableViewCell.identifier)
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
