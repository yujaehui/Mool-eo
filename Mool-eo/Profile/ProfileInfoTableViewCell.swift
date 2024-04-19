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
    
    let countStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        stackView.spacing = 20
        return stackView
    }()
    
    let followerCountView: ProfileCountView = {
        let view = ProfileCountView()
        view.contentLabel.text = "팔로워"
        return view
    }()
    
    let followingCountView: ProfileCountView = {
        let view = ProfileCountView()
        view.contentLabel.text = "팔로잉"
        return view
    }()
    
    let postCountView: ProfileCountView = {
        let view = ProfileCountView()
        view.contentLabel.text = "게시물"
        return view
    }()
    
    let nicknameLabel: CustomLabel = {
        let label = CustomLabel(type: .titleBold)
        return label
    }()
    
    let descriptionLabel: CustomLabel = {
        let label = CustomLabel(type: .content)
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
        contentView.addSubview(countStackView)
        countStackView.addArrangedSubview(followerCountView)
        countStackView.addArrangedSubview(followingCountView)
        countStackView.addArrangedSubview(postCountView)
        contentView.addSubview(nicknameLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(profileEditButton)
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
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(nicknameLabel.snp.bottom).offset(10)
            make.horizontalEdges.equalTo(contentView).inset(20)
        }
        
        profileEditButton.snp.makeConstraints { make in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(20)
            make.horizontalEdges.equalTo(contentView).inset(20)
            make.height.equalTo(40)
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
        followerCountView.countLabel.text = "\(info.followers.count)"
        followingCountView.countLabel.text = "\(info.following.count)"
        postCountView.countLabel.text = "\(info.posts.count)"
        nicknameLabel.text = info.nick
        descriptionLabel.text = info.birthDay
    }
}
