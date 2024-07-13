//
//  OtherImageChatTableViewCell.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 6/30/24.
//

import UIKit
import SnapKit

final class OtherImageChatTableViewCell: BaseTableViewCell {
    let profileImageView = ProfileImageView(frame: .zero)
    
    let nicknameLabel: CustomLabel = {
        let label = CustomLabel(type: .subDescription)
        label.numberOfLines = 1
        return label
    }()
    
    let chatImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        return imageView
    }()
    
    let chatTimeLabel = CustomLabel(type: .subDescription)
    
    override func configureHierarchy() {
        contentView.addSubview(profileImageView)
        contentView.addSubview(nicknameLabel)
        contentView.addSubview(chatImageView)
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
            make.trailing.lessThanOrEqualTo(contentView).inset(50)
            make.height.equalTo(10)
        }
        
        chatImageView.snp.makeConstraints { make in
            make.top.equalTo(nicknameLabel.snp.bottom).offset(5)
            make.leading.equalTo(profileImageView.snp.trailing).offset(5)
            make.size.equalTo(180)
            make.bottom.equalTo(contentView).inset(5)
        }
        
        chatTimeLabel.snp.makeConstraints { make in
            make.leading.equalTo(chatImageView.snp.trailing).offset(5)
            make.bottom.equalTo(chatImageView.snp.bottom)
        }
    }
    
    func configureCell(_ chat: Chat, lastSender: Sender?) {
        if let sender = lastSender {
            URLImageSettingManager.shared.setImageWithUrl(profileImageView, urlString: sender.profileImage)
            nicknameLabel.text = sender.nick
        }
        URLImageSettingManager.shared.setImageWithUrl(chatImageView, urlString: chat.filesArray.first!)
        chatTimeLabel.text = DateFormatterManager.shared.formatTimeToString(timeString: chat.createdAt)
    }
}
