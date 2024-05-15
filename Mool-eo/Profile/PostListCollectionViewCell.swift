//
//  PostListCollectionViewCell.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/15/24.
//

import UIKit
import SnapKit
import Kingfisher
import RxSwift
import RxCocoa

// 이미지가 있는 게시글일 경우 사용할 Cell
class PostListCollectionViewCell: BaseCollectionViewCell {
    
    var disposeBag = DisposeBag()
    
    let postBoardLabel: CustomLabel = {
        let label = CustomLabel(type: .colorDescriptionBold)
        return label
    }()
    
    let postTitleLabel: CustomLabel = {
        let label = CustomLabel(type: .descriptionBold)
        label.numberOfLines = 1
        return label
    }()
    
    let postContentLabel: CustomLabel = {
        let label = CustomLabel(type: .description)
        label.numberOfLines = 2
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
        disposeBag = DisposeBag()
    }
    
    override func configureHierarchy() {
        contentView.addSubview(postBoardLabel)
        contentView.addSubview(postTitleLabel)
        contentView.addSubview(postContentLabel)
        contentView.addSubview(postImageView)
        contentView.addSubview(likeIconImageView)
        contentView.addSubview(likeCountLabel)
        contentView.addSubview(commentIconImageView)
        contentView.addSubview(commentCountLabel)
    }
    
    override func configureConstraints() {
        
        postBoardLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView).inset(10)
            make.horizontalEdges.equalTo(contentView).inset(20)
        }
        
        postTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(postBoardLabel.snp.bottom).offset(5)
            make.horizontalEdges.equalTo(contentView).inset(20)
        }
        
        postContentLabel.snp.makeConstraints { make in
            make.top.equalTo(postTitleLabel.snp.bottom).offset(5)
            make.leading.equalTo(contentView).inset(20)
        }
        
        likeIconImageView.snp.makeConstraints { make in
            make.top.equalTo(postContentLabel.snp.bottom).offset(20)
            make.leading.equalTo(contentView).inset(20)
            make.bottom.lessThanOrEqualTo(contentView).inset(10)
            make.size.equalTo(20)
        }
        
        likeCountLabel.snp.makeConstraints { make in
            make.centerY.equalTo(likeIconImageView.snp.centerY)
            make.leading.equalTo(likeIconImageView.snp.trailing).offset(5)
        }
        
        commentIconImageView.snp.makeConstraints { make in
            make.top.equalTo(postContentLabel.snp.bottom).offset(20)
            make.leading.equalTo(likeCountLabel.snp.trailing).offset(20)
            make.bottom.lessThanOrEqualTo(contentView).inset(10)
            make.size.equalTo(20)
        }
        
        commentCountLabel.snp.makeConstraints { make in
            make.centerY.equalTo(commentIconImageView.snp.centerY)
            make.leading.equalTo(commentIconImageView.snp.trailing).offset(5)
        }
        
        postImageView.snp.makeConstraints { make in
            make.top.equalTo(postBoardLabel.snp.top)
            make.bottom.equalTo(likeIconImageView.snp.bottom)
            make.leading.equalTo(postContentLabel.snp.trailing).offset(10)
            make.trailing.equalTo(contentView).inset(20)
            make.width.equalTo(postImageView.snp.height)
        }
    }
    
    func configureCell(item: PostListSectionModel.Item) {
        URLImageSettingManager.shared.setImageWithUrl(postImageView, urlString: item.files.first!)
        postTitleLabel.text = item.title
        postContentLabel.text = item.content
        likeCountLabel.text = "\(item.likePost.count)"
        commentCountLabel.text = "\(item.comments.count)"
    }
}
