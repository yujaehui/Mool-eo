//
//  ProfileInfoTableViewCell.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/17/24.
//

import UIKit
import SnapKit
import RxSwift
import Kingfisher

class ProfileInfoTableViewCell: BaseTableViewCell {
    
    var disposeBag = DisposeBag()
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = ColorStyle.point
        imageView.backgroundColor = ColorStyle.subBackground
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20
        return imageView
    }()
    
    let nameLabel: CustomLabel = {
        let label = CustomLabel(type: .titleBold)
        label.text = "리치"
        return label
    }()
    
    let ageLabel: CustomLabel = {
        let label = CustomLabel(type: .content)
        label.text = "2021년 6월 15일에 태어났어요 ☺️"
        return label
    }()
    
    
    let idLabel: CustomLabel = {
        let label = CustomLabel(type: .subContent)
        label.text = "chchri"
        return label
    }()
    
    let followerAndFollowingLabel: CustomLabel = {
        let label = CustomLabel(type: .contentBold)
        label.text = "팔로워 23,341명 · 팔로잉 323명"
        return label
    }()
    
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
        contentView.addSubview(nameLabel)
        contentView.addSubview(ageLabel)
        contentView.addSubview(idLabel)
        contentView.addSubview(followerAndFollowingLabel)
        contentView.addSubview(profileEditButton)
    }
    
    override func configureConstraints() {
        profileImageView.snp.makeConstraints { make in
            make.top.equalTo(contentView).inset(10)
            make.centerX.equalTo(contentView)
            make.size.equalTo(100)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(10)
            make.centerX.equalTo(contentView)
        }
        
        ageLabel.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(10)
            make.centerX.equalTo(contentView)
        }
        
        idLabel.snp.makeConstraints { make in
            make.top.equalTo(ageLabel.snp.bottom).offset(10)
            make.centerX.equalTo(contentView)
        }
        
        followerAndFollowingLabel.snp.makeConstraints { make in
            make.top.equalTo(idLabel.snp.bottom).offset(10)
            make.centerX.equalTo(contentView)
        }
        
        profileEditButton.snp.makeConstraints { make in
            make.top.equalTo(followerAndFollowingLabel.snp.bottom).offset(10)
            make.centerX.equalTo(contentView)
            make.bottom.lessThanOrEqualTo(contentView).inset(10)
        }
    }
    
    func configureCell(_ info: ProfileModel) {
        let url = URL(string: APIKey.baseURL.rawValue + info.profileImage)
        let modifier = AnyModifier { request in
            var urlRequest = request
            urlRequest.headers = [HTTPHeader.sesacKey.rawValue : APIKey.secretKey.rawValue,
                                  HTTPHeader.authorization.rawValue : UserDefaults.standard.string(forKey: "accessToken")!]
            return urlRequest
        }
        profileImageView.kf.setImage(with: url, options: [.requestModifier(modifier)])
        nameLabel.text = info.nick
        ageLabel.text = info.birthDay
        idLabel.text = info.email
        followerAndFollowingLabel.text = "팔로워 \(info.followers.count)명 · 팔로잉 \(info.following.count)명"
    }
}
