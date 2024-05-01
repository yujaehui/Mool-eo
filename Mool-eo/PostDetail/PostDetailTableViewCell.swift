//
//  PostDetailTableViewCell.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/20/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

// 이미지가 있는 게시글일 경우 사용할 Cell
class PostDetailTableViewCell: BaseTableViewCell {
    
    var disposeBag = DisposeBag()
    
    let profileImageView = CustomImageView(frame: .zero)
    
    let nickNameLabel = CustomLabel(type: .descriptionBold)
    
    let postTitleLabel: CustomLabel = {
        let label = CustomLabel(type: .contentBold)
        label.numberOfLines = 1
        return label
    }()
    
    let postContentLabel: CustomLabel = {
        let label = CustomLabel(type: .content)
        label.numberOfLines = 0
        return label
    }()
    
    let postImageCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: configureCollectionViewLayout())
        collectionView.register(PostImageCollectionViewCell.self, forCellWithReuseIdentifier: PostImageCollectionViewCell.identifier)
        collectionView.isPagingEnabled = true
        return collectionView
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
    
    // TODO: 버튼 디자인 수정 필요
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    override func configureHierarchy() {
        contentView.addSubview(profileImageView)
        contentView.addSubview(nickNameLabel)
        contentView.addSubview(postTitleLabel)
        contentView.addSubview(postContentLabel)
        contentView.addSubview(postImageCollectionView)
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
            make.trailing.equalTo(contentView).inset(20)
        }
        
        postTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(10)
            make.horizontalEdges.equalTo(contentView).inset(20)
        }
        
        postContentLabel.snp.makeConstraints { make in
            make.top.equalTo(postTitleLabel.snp.bottom).offset(10)
            make.horizontalEdges.equalTo(contentView).inset(20)
        }
        
        postImageCollectionView.snp.makeConstraints { make in
            make.top.equalTo(postContentLabel.snp.bottom).offset(10)
            make.horizontalEdges.equalTo(contentView)
            make.height.equalTo(postImageCollectionView.snp.width)
        }
        
        likeIconImageView.snp.makeConstraints { make in
            make.top.equalTo(postImageCollectionView.snp.bottom).offset(20)
            make.leading.equalTo(contentView).inset(20)
            make.size.equalTo(20)
        }
        
        likeCountLabel.snp.makeConstraints { make in
            make.centerY.equalTo(likeIconImageView.snp.centerY)
            make.top.equalTo(postImageCollectionView.snp.bottom).offset(20)
            make.leading.equalTo(likeIconImageView.snp.trailing).offset(5)
        }
        
        commentIconImageView.snp.makeConstraints { make in
            make.top.equalTo(postImageCollectionView.snp.bottom).offset(20)
            make.leading.equalTo(likeCountLabel.snp.trailing).offset(20)
            make.size.equalTo(20)
        }
        
        commentCountLabel.snp.makeConstraints { make in
            make.centerY.equalTo(commentIconImageView.snp.centerY)
            make.top.equalTo(postImageCollectionView.snp.bottom).offset(20)
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
    
    private static func configureCollectionViewLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.width)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.scrollDirection = .horizontal
        return layout
    }
    
    func configureCell(post: PostModel) {
        Observable.just(post.files).bind(to: postImageCollectionView.rx.items(cellIdentifier: PostImageCollectionViewCell.identifier, cellType: PostImageCollectionViewCell.self)) { (row, element, cell) in
            URLImageSettingManager.shared.setImageWithUrl(cell.postImageView, urlString: element)
        }.disposed(by: disposeBag)
        URLImageSettingManager.shared.setImageWithUrl(profileImageView, urlString: post.creator.profileImage)
        postTitleLabel.text = post.title
        postContentLabel.text = post.content
        likeCountLabel.text = "\(post.likes.count)"
        commentCountLabel.text = "\(post.comments.count)"
        nickNameLabel.text = post.creator.nick
    }
}
