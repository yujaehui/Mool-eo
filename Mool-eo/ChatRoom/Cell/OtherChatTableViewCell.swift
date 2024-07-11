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
    
    override func configureHierarchy() {
        contentView.addSubview(profileImageView)
        contentView.addSubview(nicknameLabel)
        contentView.addSubview(chatView)
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
            make.trailing.lessThanOrEqualTo(contentView).inset(50)
            make.height.equalTo(10)
        }
        
        chatView.snp.makeConstraints { make in
            make.top.equalTo(nicknameLabel.snp.bottom).offset(5)
            make.leading.equalTo(profileImageView.snp.trailing).offset(5)
            make.trailing.lessThanOrEqualTo(contentView).inset(50)
            make.bottom.lessThanOrEqualTo(contentView).inset(5)
        }
    }
    
    func configureCell(_ chat: Chat) {
        if let sender = chat.sender {
            URLImageSettingManager.shared.setImageWithUrl(profileImageView, urlString: sender.profileImage)
            nicknameLabel.text = sender.nick
        }
        chatView.chatLabel.text = chat.content
    }
}
