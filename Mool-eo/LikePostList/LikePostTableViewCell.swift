//
//  LikeMyPostTableViewCell.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/17/24.
//

import UIKit
import SnapKit

final class LikePostTableViewCell: BaseTableViewCell {
    
    let postTitleLabel: CustomLabel = {
        let label = CustomLabel(type: .contentBold)
        label.numberOfLines = 1
        return label
    }()
    
    let postContentLabel: CustomLabel = {
        let label = CustomLabel(type: .content)
        label.numberOfLines = 3
        return label
    }()
    
    let postImageView = PostImageView(frame: .zero)
    
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        postImageView.image = nil
    }
        
    override func configureHierarchy() {
        contentView.addSubview(postTitleLabel)
        contentView.addSubview(postContentLabel)
        contentView.addSubview(postImageView)
        contentView.addSubview(likeIconImageView)
        contentView.addSubview(likeCountLabel)
        contentView.addSubview(commentIconImageView)
        contentView.addSubview(commentCountLabel)
    }
    
    override func configureConstraints() {
        
        postTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView).inset(10)
            make.horizontalEdges.equalTo(contentView).inset(20)
        }
        
        postContentLabel.snp.makeConstraints { make in
            make.top.equalTo(postTitleLabel.snp.bottom).offset(10)
            make.leading.equalTo(contentView).inset(20)
        }
        
        postImageView.snp.makeConstraints { make in
            make.top.equalTo(postTitleLabel.snp.top)
            make.leading.equalTo(postContentLabel.snp.trailing).offset(10)
            make.trailing.equalTo(contentView).inset(20)
            make.size.equalTo(80)
        }
        
        likeIconImageView.snp.makeConstraints { make in
            make.top.equalTo(postImageView.snp.bottom).offset(20)
            make.leading.equalTo(contentView).inset(20)
            make.size.equalTo(20)
            make.bottom.lessThanOrEqualTo(contentView).inset(10)
        }
        
        likeCountLabel.snp.makeConstraints { make in
            make.centerY.equalTo(likeIconImageView.snp.centerY)
            make.leading.equalTo(likeIconImageView.snp.trailing).offset(5)
        }
        
        commentIconImageView.snp.makeConstraints { make in
            make.top.equalTo(postImageView.snp.bottom).offset(20)
            make.leading.equalTo(likeCountLabel.snp.trailing).offset(20)
            make.size.equalTo(20)
            make.bottom.lessThanOrEqualTo(contentView).inset(10)
        }
        
        commentCountLabel.snp.makeConstraints { make in
            make.centerY.equalTo(commentIconImageView.snp.centerY)
            make.leading.equalTo(commentIconImageView.snp.trailing).offset(5)
        }
    }
    
    func configureCell(myPost: PostModel) {
        if let firstFile = myPost.files.first {
            URLImageSettingManager.shared.setImageWithUrl(postImageView, urlString: firstFile, imageViewSize: .medium)
        }
        postTitleLabel.text = myPost.title
        postContentLabel.text = myPost.content
        likeCountLabel.text = "\(myPost.likePost.count)"
        commentCountLabel.text = "\(myPost.comments.count)"
    }
}
