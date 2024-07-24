//
//  UserProfileInfoCollectionViewCell.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 7/1/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class UserProfileInfoCollectionViewCell: BaseCollectionViewCell {
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
    
    let profileEditButton: UIButton = {
        let button = UIButton()
        button.configuration = .check2("프로필 수정")
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
        contentView.addSubview(profileEditButton)
    }
    
    override func configureConstraints() {
        profileImageView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).inset(10)
            make.leading.equalTo(safeAreaLayoutGuide).inset(20)
            make.size.equalTo(80)
        }
        
        stackView.snp.makeConstraints { make in
            make.centerY.equalTo(profileImageView.snp.centerY)
            make.leading.equalTo(profileImageView.snp.trailing).offset(20)
            make.trailing.equalTo(safeAreaLayoutGuide).inset(20)
        }
        
        profileEditButton.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(10)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(20)
            make.height.equalTo(30)
            make.bottom.lessThanOrEqualTo(contentView).inset(10)
        }
    }
    
    func configureCell(_ info: ProfileModel) {
        URLImageSettingManager.shared.setImageWithUrl(profileImageView, urlString: info.profileImage, imageViewSize: .medium)
        nicknameLabel.text = info.nick
        followLabel.text = "팔로워 \(info.followers.count) | 팔로잉 \(info.following.count)"
    }
}
