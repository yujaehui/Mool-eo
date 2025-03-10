//
//  ChatListTableViewCell.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/19/24.
//

import UIKit
import SnapKit

final class ChatListTableViewCell: BaseTableViewCell {
    
    let profileImageView = ProfileImageView(frame: .zero)
    
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .leading
        stackView.spacing = 5
        return stackView
    }()
    
    let nicknameLabel: CustomLabel = {
        let label = CustomLabel(type: .titleBold)
        label.numberOfLines = 1
        return label
    }()
    
    let lastChatLabel: CustomLabel = {
        let label = CustomLabel(type: .subContent)
        label.numberOfLines = 2
        return label
    }()
    
    let lastChatTimeLabel: CustomLabel = {
        let label = CustomLabel(type: .subDescription)
        label.numberOfLines = 1
        return label
    }()
    
    override func configureHierarchy() {
        contentView.addSubview(profileImageView)
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(nicknameLabel)
        stackView.addArrangedSubview(lastChatLabel)
        contentView.addSubview(lastChatTimeLabel)
    }
    
    override func configureConstraints() {
        profileImageView.snp.makeConstraints { make in
            make.top.equalTo(contentView).inset(10)
            make.leading.equalTo(contentView).inset(20)
            make.size.equalTo(60)
            make.bottom.lessThanOrEqualTo(contentView).inset(10)
        }
        
        stackView.snp.makeConstraints { make in
            make.centerY.equalTo(profileImageView.snp.centerY)
            make.leading.equalTo(profileImageView.snp.trailing).offset(10)
            make.trailing.equalTo(contentView).inset(10)
        }
        
        lastChatTimeLabel.snp.makeConstraints { make in
            make.centerY.equalTo(nicknameLabel.snp.centerY)
            make.trailing.equalTo(contentView).inset(10)
        }
    }
    
    func configureCell(_ chat: ChatRoomModel) {
        URLImageSettingManager.shared.setImageWithUrl(profileImageView, urlString: findOtherParticipant(chat).profileImage, imageViewSize: .medium)
        nicknameLabel.text = findOtherParticipant(chat).nick
        lastChatLabel.text = lastMessageIsImage(chat)
        lastChatTimeLabel.text = DateFormatterManager.shared.formatDateToString(dateString: chat.lastChat.createdAt)
    }
    
    func findOtherParticipant(_ chat: ChatRoomModel) -> Sender {
        var otherParticipant = Sender()
        for participant in chat.participants {
            if participant.user_id == UserDefaultsManager.userId {
                continue
            } else {
                otherParticipant = participant
            }
        }
        return otherParticipant
    }

    func lastMessageIsImage(_ chat: ChatRoomModel) -> String {
        return chat.lastChat.files.isEmpty ? chat.lastChat.content : "이미지"
    }
}
