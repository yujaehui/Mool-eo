//
//  PostListWithoutImageTableViewCell.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/20/24.
//

import UIKit
import SnapKit
import Kingfisher
import RxSwift
import RxCocoa

// 이미지가 없는 게시글일 경우 사용할 Cell
class PostListWithoutImageTableViewCell: BaseTableViewCell {
    
    var disposeBag = DisposeBag()
    
    let profileStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .leading
        stackView.spacing = 10
        return stackView
    }()
    
    let profileImageView = ProfileImageView(frame: .zero)
    
    let nickNameLabel = CustomLabel(type: .descriptionBold)
    
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
        
    override func configureHierarchy() {
        contentView.addSubview(profileStackView)
        profileStackView.addArrangedSubview(profileImageView)
        profileStackView.addArrangedSubview(nickNameLabel)
        contentView.addSubview(postTitleLabel)
        contentView.addSubview(postContentLabel)
        contentView.addSubview(likeIconImageView)
        contentView.addSubview(likeCountLabel)
        contentView.addSubview(commentIconImageView)
        contentView.addSubview(commentCountLabel)
    }
    
    override func configureConstraints() {
        profileStackView.snp.makeConstraints { make in
            make.top.equalTo(contentView).inset(10)
            make.horizontalEdges.equalTo(contentView).inset(20)
            make.height.equalTo(50)
        }
        
        profileImageView.snp.makeConstraints { make in
            make.size.equalTo(50)
        }
        
        nickNameLabel.snp.makeConstraints { make in
            make.centerY.equalTo(profileImageView.snp.centerY)
        }
        
        postTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(profileStackView.snp.bottom).offset(10)
            make.horizontalEdges.equalTo(contentView).inset(20)
        }
        
        postContentLabel.snp.makeConstraints { make in
            make.top.equalTo(postTitleLabel.snp.bottom).offset(10)
            make.horizontalEdges.equalTo(contentView).inset(20)
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
    }

    func configureCell(item: PostListSectionModel.Item) {
        URLImageSettingManager.shared.setImageWithUrl(profileImageView, urlString: item.creator.profileImage)
        nickNameLabel.text = item.creator.nick
        postTitleLabel.text = item.title
        postContentLabel.text = item.content
        likeCountLabel.text = "\(item.likes.count)"
        commentCountLabel.text = "\(item.comments.count)"
    }
}
