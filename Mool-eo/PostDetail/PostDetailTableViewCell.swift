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
        label.numberOfLines = 0
        return label
    }()
    
    let postImageCollectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: configureCollectionViewLayout())
        collectionView.register(PostImageCollectionViewCell.self, forCellWithReuseIdentifier: PostImageCollectionViewCell.identifier)
        collectionView.isPagingEnabled = true
        return collectionView
    }()

    let likeButton: UIButton = {
        let button = UIButton()
        return button
    }()
    
    let lineView = LineView()
    
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
        contentView.addSubview(postImageCollectionView)
        contentView.addSubview(likeButton)
        contentView.addSubview(lineView)
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
        
        postImageCollectionView.snp.makeConstraints { make in
            make.top.equalTo(postContentLabel.snp.bottom).offset(10)
            make.horizontalEdges.equalTo(contentView)
            make.height.equalTo(postImageCollectionView.snp.width)
        }
        
        likeButton.snp.makeConstraints { make in
            make.top.equalTo(postImageCollectionView.snp.bottom).offset(20)
            make.leading.equalTo(contentView).inset(20)
        }
        
        lineView.snp.makeConstraints { make in
            make.top.equalTo(likeButton.snp.bottom).offset(20)
            make.horizontalEdges.equalTo(contentView).inset(20)
            make.height.equalTo(1)
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
            cell.postImageCountLabel.text = "\(row+1)/\(post.files.count)"
        }.disposed(by: disposeBag)
        URLImageSettingManager.shared.setImageWithUrl(profileImageView, urlString: post.creator.profileImage)
        postTitleLabel.text = post.title
        postContentLabel.text = post.content
        likeButton.configuration = post.likePost.contains(UserDefaultsManager.userId!) ? .heart("heart.fill") : .heart("heart")
        nickNameLabel.text = post.creator.nick
    }
}
