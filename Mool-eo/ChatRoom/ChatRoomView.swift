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
        tableView.register(OtherChatTableViewCell.self, forCellReuseIdentifier: OtherChatTableViewCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        return tableView
    }()
    
    let chatTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = ColorStyle.subBackground
        return textField
    }()
    
    override func configureHierarchy() {
        addSubview(tableView)
        addSubview(chatTextField)
    }
    
    override func configureConstraints() {
        tableView.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(safeAreaLayoutGuide)
            make.bottom.equalTo(chatTextField.snp.top).offset(-10)
        }
        
        chatTextField.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(10)
            make.bottom.equalTo(safeAreaLayoutGuide).inset(10)
            make.height.equalTo(30)
        }
    }
}
