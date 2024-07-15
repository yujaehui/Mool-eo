//
//  MyChatTableViewCell.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/19/24.
//

import UIKit
import SnapKit

final class MyChatTableViewCell: BaseTableViewCell {
    let chatView = ChatContentView()
    
    let chatTimeLabel = CustomLabel(type: .subDescription)
    
    override func configureHierarchy() {
        contentView.addSubview(chatView)
        contentView.addSubview(chatTimeLabel)
    }
    
    override func configureConstraints() {
        chatView.snp.makeConstraints { make in
            make.top.equalTo(contentView).inset(5)
            make.trailing.equalTo(contentView).inset(10)
            make.width.lessThanOrEqualTo(240)
            make.bottom.lessThanOrEqualTo(contentView).inset(5)
        }
        
        chatTimeLabel.snp.makeConstraints { make in
            make.trailing.equalTo(chatView.snp.leading).offset(-5)
            make.bottom.equalTo(chatView.snp.bottom)
        }
    }
    
    func configureCell(_ chat: Chat, showTime: Bool) {
        chatView.chatLabel.text = chat.content
        chatTimeLabel.text = DateFormatterManager.shared.formatTimeToString(timeString: chat.createdAt)
        chatTimeLabel.isHidden = !showTime
    }
}
