//
//  PostListView.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/20/24.
//

import UIKit
import SnapKit

final class PostListView: BaseView {
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(PostListTableViewCell.self, forCellReuseIdentifier: PostListTableViewCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension
        return tableView
    }()
    
    let postWriteButton: UIButton = {
        let button = UIButton()
        button.configuration = .postAdd("글쓰기")
        return button
    }()
    
    override func configureHierarchy() {
        addSubview(tableView)
        addSubview(postWriteButton)
    }
    
    override func configureConstraints() {
        tableView.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide)
        }
        
        postWriteButton.snp.makeConstraints { make in
            make.bottom.equalTo(safeAreaLayoutGuide).inset(20)
            make.trailing.equalTo(safeAreaLayoutGuide).inset(20)
        }
    }
}
