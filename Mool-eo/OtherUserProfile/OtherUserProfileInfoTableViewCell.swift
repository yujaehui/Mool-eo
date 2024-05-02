//
//  OtherUserProfileInfoTableViewCell.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/2/24.
//

import UIKit
import SnapKit
import RxSwift
import Kingfisher

class OtherUserProfileInfoTableViewCell: BaseTableViewCell {
    
    var disposeBag = DisposeBag()
    
    let profileImageView = CustomImageView(frame: .zero)
    
    let countStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.spacing = 20
        return stackView
    }()
    
    let followerCountView = ProfileCountView(frame: .zero, profileCountType: .follower)

    let followingCountView = ProfileCountView(frame: .zero, profileCountType: .following)
    
    let postCountView = ProfileCountView(frame: .zero, profileCountType: .post)
    
    let nicknameLabel = CustomLabel(type: .titleBold)
    
    let introductionLabel = CustomLabel(type: .content)
    
    let followButton: UIButton = {
        let button = UIButton()
        button.configuration = .check2("팔로우")
        return button
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    override func configureHierarchy() {
        contentView.addSubview(profileImageView)
        contentView.addSubview(countStackView)
        countStackView.addArrangedSubview(followerCountView)
        countStackView.addArrangedSubview(followingCountView)
        countStackView.addArrangedSubview(postCountView)
        contentView.addSubview(nicknameLabel)
        contentView.addSubview(introductionLabel)
        contentView.addSubview(followButton)
    }
    
    override func configureConstraints() {
        profileImageView.snp.makeConstraints { make in
            make.top.equalTo(contentView).inset(10)
            make.leading.equalTo(contentView).inset(20)
            make.size.equalTo(100)
        }
        
        countStackView.snp.makeConstraints { make in
            make.centerY.equalTo(profileImageView.snp.centerY)
            make.leading.equalTo(profileImageView.snp.trailing).offset(20)
            make.trailing.equalTo(contentView).inset(20)
        }
        
        nicknameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(20)
            make.horizontalEdges.equalTo(contentView).inset(20)
        }
        
        introductionLabel.snp.makeConstraints { make in
            make.top.equalTo(nicknameLabel.snp.bottom).offset(10)
            make.horizontalEdges.equalTo(contentView).inset(20)
        }
        
        followButton.snp.makeConstraints { make in
            make.top.equalTo(introductionLabel.snp.bottom).offset(20)
            make.horizontalEdges.equalTo(contentView).inset(20)
            make.height.equalTo(40)
            make.bottom.lessThanOrEqualTo(contentView).inset(10)
        }
    }
    
    func configureCell(_ info: OtherUserProfileModel) {
        URLImageSettingManager.shared.setImageWithUrl(profileImageView, urlString: info.profileImage)
        followerCountView.countLabel.text = "\(info.followers.count)"
        followingCountView.countLabel.text = "\(info.following.count)"
        postCountView.countLabel.text = "\(info.posts.count)"
        nicknameLabel.text = info.nick
    }
}
