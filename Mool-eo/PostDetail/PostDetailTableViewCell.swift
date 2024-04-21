//
//  PostDetailTableViewCell.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/20/24.
//

import UIKit
import SnapKit

class PostDetailTableViewCell: BaseTableViewCell {
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = ColorStyle.point
        imageView.backgroundColor = ColorStyle.subBackground
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20
        return imageView
    }()
    
    let nickNameLabel: CustomLabel = {
        let label = CustomLabel(type: .descriptionBold)
        label.text = "닉네임 테스트"
        return label
    }()
    
    let postTitleLabel: CustomLabel = {
        let label = CustomLabel(type: .contentBold)
        label.numberOfLines = 1
        return label
    }()
    
    let postContentLabel: CustomLabel = {
        let label = CustomLabel(type: .content)
        label.numberOfLines = 4
        return label
    }()
    
    let postImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = ColorStyle.point
        imageView.backgroundColor = ColorStyle.subBackground
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20
        return imageView
    }()
    
    let likeIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "heart")
        imageView.tintColor = ColorStyle.point
        return imageView
    }()
    
    let likeCountLabel: CustomLabel = {
        let label = CustomLabel(type: .description)
        return label
    }()
    
    let commentIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "bubble")
        imageView.tintColor = ColorStyle.point
        return imageView
    }()
    
    let commentCountLabel: CustomLabel = {
        let label = CustomLabel(type: .description)
        return label
    }()
    
    let likeButton: UIButton = {
        let button = UIButton()
        button.configuration = .capsule("좋아요")
        return button
    }()
    
    let scrapButton: UIButton = {
        let button = UIButton()
        button.configuration = .capsule("스크랩")
        return button
    }()
    
    override func configureHierarchy() {
        contentView.addSubview(profileImageView)
        contentView.addSubview(nickNameLabel)
        contentView.addSubview(postTitleLabel)
        contentView.addSubview(postContentLabel)
        contentView.addSubview(postImageView)
        contentView.addSubview(likeIconImageView)
        contentView.addSubview(likeCountLabel)
        contentView.addSubview(commentIconImageView)
        contentView.addSubview(commentCountLabel)
        contentView.addSubview(likeButton)
        contentView.addSubview(scrapButton)
    }
    
    override func configureConstraints() {
        profileImageView.snp.makeConstraints { make in
            make.top.equalTo(contentView).inset(10)
            make.leading.equalTo(contentView).inset(20)
            make.size.equalTo(50)
        }
        
        nickNameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(profileImageView.snp.centerY)
            make.leading.equalTo(profileImageView.snp.trailing).offset(10)
        }
        
        postTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(10)
            make.horizontalEdges.equalTo(contentView).inset(20)
        }
        
        postContentLabel.snp.makeConstraints { make in
            make.top.equalTo(postTitleLabel.snp.bottom).offset(10)
            make.horizontalEdges.equalTo(contentView).inset(20)
        }
        
        postImageView.snp.makeConstraints { make in
            make.top.equalTo(postContentLabel.snp.bottom).offset(10)
            make.horizontalEdges.equalTo(contentView).inset(20)
            make.height.equalTo(postImageView.snp.width)
        }
        
        likeIconImageView.snp.makeConstraints { make in
            make.top.equalTo(postImageView.snp.bottom).offset(20)
            make.leading.equalTo(contentView).inset(20)
            make.size.equalTo(20)
        }
        
        likeCountLabel.snp.makeConstraints { make in
            make.centerY.equalTo(likeIconImageView.snp.centerY)
            make.top.equalTo(postImageView.snp.bottom).offset(20)
            make.leading.equalTo(likeIconImageView.snp.trailing).offset(5)
        }
        
        commentIconImageView.snp.makeConstraints { make in
            make.top.equalTo(postImageView.snp.bottom).offset(20)
            make.leading.equalTo(likeCountLabel.snp.trailing).offset(20)
            make.size.equalTo(20)
        }
        
        commentCountLabel.snp.makeConstraints { make in
            make.centerY.equalTo(commentIconImageView.snp.centerY)
            make.top.equalTo(postImageView.snp.bottom).offset(20)
            make.leading.equalTo(commentIconImageView.snp.trailing).offset(5)
        }
        
        likeButton.snp.makeConstraints { make in
            make.top.equalTo(likeIconImageView.snp.bottom).offset(10)
            make.leading.equalTo(contentView).inset(20)
            make.bottom.lessThanOrEqualTo(contentView).inset(10)
        }
        
        scrapButton.snp.makeConstraints { make in
            make.top.equalTo(likeIconImageView.snp.bottom).offset(10)
            make.leading.equalTo(likeButton.snp.trailing).offset(10)
            make.bottom.lessThanOrEqualTo(contentView).inset(10)
        }
    }
    
}
