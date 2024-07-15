//
//  OtherChatTableViewCell.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/19/24.
//

import UIKit
import SnapKit

final class OtherChatTableViewCell: BaseTableViewCell {
    let profileImageView = ProfileImageView(frame: .zero)
    
    let nicknameLabel: CustomLabel = {
        let label = CustomLabel(type: .subDescription)
        label.numberOfLines = 1
        return label
    }()
    
    let chatView = OtherChatContentView()
    
    let chatTimeLabel = CustomLabel(type: .subDescription)
    
    override func configureHierarchy() {
        contentView.addSubview(profileImageView)
        contentView.addSubview(nicknameLabel)
        contentView.addSubview(chatView)
        contentView.addSubview(chatTimeLabel)
    }
    
    override func configureConstraints() {
        profileImageView.snp.makeConstraints { make in
            make.top.equalTo(contentView).inset(5)
            make.leading.equalTo(contentView).inset(10)
            make.size.equalTo(40)
        }
        
        nicknameLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView).inset(5)
            make.leading.equalTo(profileImageView.snp.trailing).offset(5)
            make.width.lessThanOrEqualTo(240)
            make.height.equalTo(10)
        }
        
        chatView.snp.makeConstraints { make in
            make.top.equalTo(nicknameLabel.snp.bottom).offset(5)
            make.leading.equalTo(profileImageView.snp.trailing).offset(5)
            make.width.lessThanOrEqualTo(240)
            make.bottom.lessThanOrEqualTo(contentView).inset(5)
        }
        
        chatTimeLabel.snp.makeConstraints { make in
            make.leading.equalTo(chatView.snp.trailing).offset(5)
            make.bottom.equalTo(chatView.snp.bottom)
        }
    }
    
    func configureCell(_ chat: Chat, lastSender: Sender?, showTime: Bool) {
        if let sender = lastSender {
            URLImageSettingManager.shared.setImageWithUrl(profileImageView, urlString: sender.profileImage)
            nicknameLabel.text = sender.nick
        }
        chatView.chatLabel.text = chat.content
        chatTimeLabel.text = DateFormatterManager.shared.formatTimeToString(timeString: chat.createdAt)
        chatTimeLabel.isHidden = !showTime
    }
}
