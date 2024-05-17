//
//  OtherUserProfileCollectionViewCell.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/16/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

class OtherUserProfileCollectionViewCell: BaseCollectionViewCell {
    
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
    
    let followLabel: CustomLabel = {
        let label = CustomLabel(type: .content)
        return label
    }()
    
    let followButton: UIButton = {
        let button = UIButton()
        button.configuration = .capsule("팔로우")
        return button
    }()
    
    let lineView = LineView()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    override func configureHierarchy() {
        contentView.addSubview(profileImageView)
        contentView.addSubview(stackView)
        stackView.addArrangedSubview(nicknameLabel)
        stackView.addArrangedSubview(followLabel)
        contentView.addSubview(followButton)
        contentView.addSubview(lineView)
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
        
        followButton.snp.makeConstraints { make in
            make.centerY.equalTo(nicknameLabel.snp.centerY)
            make.trailing.equalTo(contentView).inset(20)
        }
        
        lineView.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(20)
            make.horizontalEdges.equalTo(contentView).inset(20)
            make.height.equalTo(5)
            make.bottom.lessThanOrEqualTo(contentView).inset(10)
        }
    }
    
    func configureCell(_ info: OtherUserProfileModel) {
        URLImageSettingManager.shared.setImageWithUrl(profileImageView, urlString: info.profileImage)
        nicknameLabel.text = info.nick
        followLabel.text = "팔로워 \(info.followers.count) | 팔로잉 \(info.following.count)"
    }
}
