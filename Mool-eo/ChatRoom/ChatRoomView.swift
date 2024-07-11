//
//  ChatRoomView.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/19/24.
//

import UIKit
import SnapKit

final class ChatRoomView: BaseView {
    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(MyChatTableViewCell.self, forCellReuseIdentifier: MyChatTableViewCell.identifier)
        tableView.register(MyImageChatTableViewCell.self, forCellReuseIdentifier: MyImageChatTableViewCell.identifier)
        tableView.register(MyTwoImageChatTableViewCell.self, forCellReuseIdentifier: MyTwoImageChatTableViewCell.identifier)
        tableView.register(MyThreeImageChatTableViewCell.self, forCellReuseIdentifier: MyThreeImageChatTableViewCell.identifier)
        tableView.register(OtherChatTableViewCell.self, forCellReuseIdentifier: OtherChatTableViewCell.identifier)
        tableView.register(OtherImageChatTableViewCell.self, forCellReuseIdentifier: OtherImageChatTableViewCell.identifier)
        tableView.register(OtherTwoImageChatTableViewCell.self, forCellReuseIdentifier: OtherTwoImageChatTableViewCell.identifier)
        tableView.register(OtherThreeImageChatTableViewCell.self, forCellReuseIdentifier: OtherThreeImageChatTableViewCell.identifier)
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
            make.horizontalEdges.equalTo(safeAreaLayoutGuide)
            make.bottom.equalTo(safeAreaLayoutGuide).inset(10)
        }
    }
}
