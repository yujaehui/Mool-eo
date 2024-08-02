//
//  PostDetailView.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/20/24.
//

import UIKit
import SnapKit

final class PostDetailView: BaseView {
    
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(PostDetailTableViewCell.self, forCellReuseIdentifier: PostDetailTableViewCell.identifier)
        tableView.register(PostDetailWithoutImageTableViewCell.self, forCellReuseIdentifier: PostDetailWithoutImageTableViewCell.identifier)
        tableView.register(CommentTableViewCell.self, forCellReuseIdentifier: CommentTableViewCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        return tableView
    }()
    
    let writeCommentView = WriteContentView()
    
    override func configureHierarchy() {
        addSubview(tableView)
        addSubview(writeCommentView)
    }
    
    override func configureConstraints() {
        tableView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(safeAreaLayoutGuide)
            make.bottom.equalTo(writeCommentView.snp.top).offset(-10)
        }
        
        writeCommentView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(safeAreaLayoutGuide)
            make.bottom.equalToSuperview().inset(10)
        }
    }
}
