//
//  ChatRoomView.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/19/24.
//

import UIKit
import SnapKit

class ChatRoomView: BaseView {
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(MyChatTableViewCell.self, forCellReuseIdentifier: MyChatTableViewCell.identifier)
        tableView.register(MyImageChatTableViewCell.self, forCellReuseIdentifier: MyImageChatTableViewCell.identifier)
        tableView.register(OtherChatTableViewCell.self, forCellReuseIdentifier: OtherChatTableViewCell.identifier)
        tableView.register(OtherImageChatTableViewCell.self, forCellReuseIdentifier: OtherImageChatTableViewCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        return tableView
    }()
    
    let writeMessageView = WriteContentWithImageView()
    
    override func configureHierarchy() {
        addSubview(tableView)
        addSubview(writeMessageView)
    }
    
    override func configureConstraints() {
        tableView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(safeAreaLayoutGuide)
            make.bottom.equalTo(writeMessageView.snp.top).offset(-10)
        }
        
        writeMessageView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(10)
            make.bottom.equalTo(safeAreaLayoutGuide).inset(10)
        }
    }
}
