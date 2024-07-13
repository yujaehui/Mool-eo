//
//  MyImageChatTableViewCell.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 6/4/24.
//

import UIKit
import SnapKit

final class MyImageChatTableViewCell: BaseTableViewCell {
    let chatImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let chatTimeLabel = CustomLabel(type: .subDescription)
    
    override func configureHierarchy() {
        contentView.addSubview(chatImageView)
        contentView.addSubview(chatTimeLabel)
    }
    
    override func configureConstraints() {
        chatImageView.snp.makeConstraints { make in
            make.verticalEdges.equalTo(contentView).inset(10)
            make.trailing.equalTo(contentView).inset(10)
            make.size.equalTo(180)
        }
        
        chatTimeLabel.snp.makeConstraints { make in
            make.trailing.equalTo(chatImageView.snp.leading).offset(-5)
            make.bottom.equalTo(chatImageView.snp.bottom)
        }
    }
    
    func configureCell(_ chat: Chat) {
        URLImageSettingManager.shared.setImageWithUrl(chatImageView, urlString: chat.filesArray.first!)
        chatTimeLabel.text = DateFormatterManager.shared.formatTimeToString(timeString: chat.createdAt)
    }
}
