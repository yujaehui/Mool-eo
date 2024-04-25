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
        tableView.register(PostDetailNoCommentTableViewCell.self, forCellReuseIdentifier: PostDetailNoCommentTableViewCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        return tableView
    }()
    
    let commentTextFieldView = CommentTextFieldView()
    
    override func configureHierarchy() {
        addSubview(tableView)
        addSubview(commentTextFieldView)
    }
    
    override func configureConstraints() {
        tableView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(safeAreaLayoutGuide)
            make.bottom.equalTo(self).inset(90)
        }
        
        commentTextFieldView.snp.makeConstraints { make in
            make.bottom.equalTo(self).inset(30)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide)
            make.height.equalTo(60)
        }
    }
}
