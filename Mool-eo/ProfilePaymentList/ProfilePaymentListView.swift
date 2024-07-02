//
//  ProfilePaymentListView.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 7/2/24.
//

import UIKit
import SnapKit

final class ProfilePaymentListView: BaseView {
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(ProfilePaymentListTableViewCell.self, forCellReuseIdentifier: ProfilePaymentListTableViewCell.identifier)
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
