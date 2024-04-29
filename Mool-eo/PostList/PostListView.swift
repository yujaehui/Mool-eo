//
//  PostListView.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/20/24.
//

import UIKit
import SnapKit

class PostListView: BaseView {
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(PostListTableViewCell.self, forCellReuseIdentifier: PostListTableViewCell.identifier)
        tableView.register(PostListWithoutImageTableViewCell.self, forCellReuseIdentifier: PostListWithoutImageTableViewCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension
        return tableView
    }()
    
    let postWriteButton: UIButton = {
        let button = UIButton()
        button.configuration = .capsule("글쓰기")
        return button
    }()
    
    override func configureHierarchy() {
        addSubview(tableView)
        addSubview(postWriteButton)
    }
    
    override func configureConstraints() {
        tableView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(safeAreaLayoutGuide)
            make.bottom.equalTo(self)
        }
        
        postWriteButton.snp.makeConstraints { make in
            make.centerX.equalTo(safeAreaLayoutGuide)
            make.bottom.equalTo(safeAreaLayoutGuide).inset(10)
        }
    }
}
