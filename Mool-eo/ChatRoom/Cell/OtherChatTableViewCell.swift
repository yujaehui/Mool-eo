//
//  OtherChatTableViewCell.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/19/24.
//

import UIKit
import SnapKit

class OtherChatTableViewCell: BaseTableViewCell {
    let chatView = OtherChatContentView()
    
    override func configureHierarchy() {
        contentView.addSubview(chatView)
    }
    
    override func configureConstraints() {
        chatView.snp.makeConstraints { make in
            make.top.equalTo(contentView).inset(5)
            make.leading.equalTo(contentView).inset(10)
            make.trailing.lessThanOrEqualTo(contentView).inset(50)
            make.bottom.lessThanOrEqualTo(contentView).inset(5)
        }
    }
    
    func configureCell(_ chat: Chat) {
        chatView.chatLabel.text = chat.content
    }
}
