//
//  ProfileMyPostTableViewCell.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/17/24.
//

import UIKit
import SnapKit

// 이미지가 있는 게시글일 경우 사용할 Cell
class ProfileMyPostTableViewCell: BaseTableViewCell {
    let postBoardLabel: CustomLabel = {
        let label = CustomLabel(type: .colorContentBold)
        label.text = "게시판 테스트"
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
    
    let lineView = LineView()
    
    override func configureHierarchy() {
        contentView.addSubview(postBoardLabel)
        contentView.addSubview(postTitleLabel)
        contentView.addSubview(postContentLabel)
        contentView.addSubview(postImageView)
        contentView.addSubview(likeIconImageView)
        contentView.addSubview(likeCountLabel)
        contentView.addSubview(commentIconImageView)
        contentView.addSubview(commentCountLabel)
        contentView.addSubview(lineView)
    }
    
    override func configureConstraints() {
        postBoardLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView).inset(10)
            make.horizontalEdges.equalTo(contentView).inset(20)
        }
        
        postTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(postBoardLabel.snp.bottom).offset(10)
            make.horizontalEdges.equalTo(contentView).inset(20)
        }
        
        postContentLabel.snp.makeConstraints { make in
            make.top.equalTo(postTitleLabel.snp.bottom).offset(10)
            make.leading.equalTo(contentView).inset(20)
        }
        
        postImageView.snp.makeConstraints { make in
            make.top.equalTo(postContentLabel.snp.top)
            make.leading.equalTo(postContentLabel.snp.trailing).offset(10)
            make.trailing.equalTo(contentView).inset(20)
            make.size.equalTo(80)
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
        
        lineView.snp.makeConstraints { make in
            make.top.equalTo(likeIconImageView.snp.bottom).offset(20)
            make.horizontalEdges.equalTo(contentView).inset(20)
            make.height.equalTo(1)
            make.bottom.lessThanOrEqualTo(contentView).inset(10)
        }
    }
    
    func configureCell(myPost: PostModel) {
        URLImageSettingManager.shared.setImageWithUrl(postImageView, urlString: myPost.files.first!)
        postBoardLabel.text = myPost.productID
        postTitleLabel.text = myPost.title
        postContentLabel.text = myPost.content
        likeCountLabel.text = "\(myPost.likes.count)"
        commentCountLabel.text = "\(myPost.comments.count)"
    }
}
