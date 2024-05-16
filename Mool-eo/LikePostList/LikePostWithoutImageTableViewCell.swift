//
//  LikePostWithoutImageTableViewCell.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/19/24.
//

import UIKit
import SnapKit

// 이미지가 없는 게시글일 경우 사용할 Cell
class LikePostWithoutImageTableViewCell: BaseTableViewCell {
    
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
    
    let likeIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "heart")
        imageView.tintColor = ColorStyle.point
        return imageView
    }()
    
    let likeCountLabel = CustomLabel(type: .description)
    
    let commentIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "bubble")
        imageView.tintColor = ColorStyle.point
        return imageView
    }()
    
    let commentCountLabel = CustomLabel(type: .description)
    
    let lineView = LineView()
    
    override func configureHierarchy() {
        contentView.addSubview(postTitleLabel)
        contentView.addSubview(postContentLabel)
        contentView.addSubview(likeIconImageView)
        contentView.addSubview(likeCountLabel)
        contentView.addSubview(commentIconImageView)
        contentView.addSubview(commentCountLabel)
        contentView.addSubview(lineView)
    }
    
    override func configureConstraints() {
        
        postTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView).inset(10)
            make.horizontalEdges.equalTo(contentView).inset(20)
        }
        
        postContentLabel.snp.makeConstraints { make in
            make.top.equalTo(postTitleLabel.snp.bottom).offset(10)
            make.horizontalEdges.equalTo(contentView).inset(20)
        }
        
        likeIconImageView.snp.makeConstraints { make in
            make.top.equalTo(postContentLabel.snp.bottom).offset(20)
            make.leading.equalTo(contentView).inset(20)
            make.size.equalTo(20)
        }
        
        likeCountLabel.snp.makeConstraints { make in
            make.centerY.equalTo(likeIconImageView.snp.centerY)
            make.top.equalTo(postContentLabel.snp.bottom).offset(20)
            make.leading.equalTo(likeIconImageView.snp.trailing).offset(5)
        }
        
        commentIconImageView.snp.makeConstraints { make in
            make.top.equalTo(postContentLabel.snp.bottom).offset(20)
            make.leading.equalTo(likeCountLabel.snp.trailing).offset(20)
            make.size.equalTo(20)
        }
        
        commentCountLabel.snp.makeConstraints { make in
            make.centerY.equalTo(commentIconImageView.snp.centerY)
            make.top.equalTo(postContentLabel.snp.bottom).offset(20)
            make.leading.equalTo(commentIconImageView.snp.trailing).offset(5)
        }
        
        lineView.snp.makeConstraints { make in
            make.top.equalTo(likeIconImageView.snp.bottom).offset(20)
            make.horizontalEdges.equalTo(contentView).inset(20)
            make.height.equalTo(1)
            make.bottom.lessThanOrEqualTo(contentView).inset(10)
        }
    }
    
    func configureCell(myPost: PostModel) {
        postTitleLabel.text = myPost.title
        postContentLabel.text = myPost.content
        likeCountLabel.text = "\(myPost.likePost.count)"
        commentCountLabel.text = "\(myPost.comments.count)"
    }
}
