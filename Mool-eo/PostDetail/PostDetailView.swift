//
//  PostDetailView.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/20/24.
//

import UIKit
import SnapKit

class PostDetailView: BaseView {
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(PostDetailTableViewCell.self, forCellReuseIdentifier: PostDetailTableViewCell.identifier)
        tableView.register(PostDetailWithoutImageTableViewCell.self, forCellReuseIdentifier: PostDetailWithoutImageTableViewCell.identifier)
        tableView.register(PostDetailCommentTableViewCell.self, forCellReuseIdentifier: PostDetailCommentTableViewCell.identifier)
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
