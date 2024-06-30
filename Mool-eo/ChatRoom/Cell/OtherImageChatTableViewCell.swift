//
//  OtherImageChatTableViewCell.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 6/30/24.
//

import UIKit
import SnapKit

class OtherImageChatTableViewCell: BaseTableViewCell {
    let chatImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 10
        return imageView
    }()
    
    override func configureHierarchy() {
        contentView.addSubview(chatImageView)
    }
    
    override func configureConstraints() {
        chatImageView.snp.makeConstraints { make in
            make.verticalEdges.equalTo(contentView).inset(10)
            make.leading.equalTo(contentView).inset(10)
            make.size.equalTo(200)
        }
    }
    
    func configureCell(_ chat: Chat) {
        URLImageSettingManager.shared.setImageWithUrl(chatImageView, urlString: chat.filesArray.first!)
    }
}
