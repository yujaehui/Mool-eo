//
//  OtherUserProfileInfoCollectionViewCell.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/16/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class OtherUserProfileInfoCollectionViewCell: BaseCollectionViewCell {
    
    var disposeBag = DisposeBag()
    
    let profileImageView = ProfileImageView(frame: .zero)
    
    let stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.alignment = .leading
        stackView.distribution = .fill
        return stackView
    }()
    
    let nicknameLabel: CustomLabel = {
        let label = CustomLabel(type: .largeTitleBold)
        label.numberOfLines = 1
        return label
    }()
    
    let followLabel = CustomLabel(type: .content)
    
    let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fill
        stackView.alignment = .center
        stackView.spacing = 10
        return stackView
    }()
    
    let followButton: UIButton = {
        let button = UIButton()
        button.configuration = .check2("팔로우")
        return button
    }()
    
    let chatButton: UIButton = {
        let button = UIButton()
        button.configuration = .check2("채팅하기")
        return button
    }()
        
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    override func configureHierarchy() {
        contentView.addSubview(profileImageView)
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(nicknameLabel)
        stackView.addArrangedSubview(followLabel)
        contentView.addSubview(buttonStackView)
        buttonStackView.addArrangedSubview(followButton)
        buttonStackView.addArrangedSubview(chatButton)
    }
    
    override func configureConstraints() {
        profileImageView.snp.makeConstraints { make in
            make.top.equalTo(contentView).inset(10)
            make.leading.equalTo(contentView).inset(20)
            make.size.equalTo(80)
        }
        
        stackView.snp.makeConstraints { make in
            make.centerY.equalTo(profileImageView.snp.centerY)
            make.leading.equalTo(profileImageView.snp.trailing).offset(20)
            make.trailing.equalTo(contentView).inset(20)
        }
        
        buttonStackView.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(10)
            make.horizontalEdges.equalTo(contentView).inset(20)
            make.height.equalTo(30)
            make.bottom.lessThanOrEqualTo(contentView).inset(10)
        }
    }
    
    func configureCell(_ info: OtherUserProfileModel) {
        URLImageSettingManager.shared.setImageWithUrl(profileImageView, urlString: info.profileImage)
        nicknameLabel.text = info.nick
        followLabel.text = "팔로워 \(info.followers.count) | 팔로잉 \(info.following.count)"
        if info.followers.contains(where: { $0.user_id == UserDefaultsManager.userId }) {
            followButton.configuration = .check("팔로잉")
        } else {
            followButton.configuration = .check2("팔로우")
        }
    }
}
