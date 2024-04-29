//
//  CommentTableViewCell.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/20/24.
//

import UIKit
import SnapKit

class CommentTableViewCell: BaseTableViewCell {
    let profileImageView = CustomImageView(frame: .zero)
    
    let nicknameLabel = CustomLabel(type: .description)
    
    let commentLabel: CustomLabel = {
        let label = CustomLabel(type: .description)
        label.numberOfLines = 0
        return label
    }()
    
    override func configureHierarchy() {
        contentView.addSubview(profileImageView)
        contentView.addSubview(nicknameLabel)
        contentView.addSubview(commentLabel)
    }
    
    override func configureConstraints() {
        profileImageView.snp.makeConstraints { make in
            make.top.equalTo(contentView).inset(10)
            make.leading.equalTo(contentView).inset(20)
            make.size.equalTo(30)
        }
        
        nicknameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.top)
            make.leading.equalTo(profileImageView.snp.trailing).offset(10)
            make.trailing.equalTo(contentView).inset(20)
        }
        
        commentLabel.snp.makeConstraints { make in
            make.top.equalTo(nicknameLabel.snp.bottom).offset(10)
            make.horizontalEdges.equalTo(nicknameLabel.snp.horizontalEdges)
            make.bottom.lessThanOrEqualTo(contentView).inset(10)
        }
    }
    
    func configureCell(comment: Comment) {
        URLImageSettingManager.shared.setImageWithUrl(profileImageView, urlString: comment.creator.profileImage)
        nicknameLabel.text = comment.creator.nick
        commentLabel.text = comment.content
    }
}
