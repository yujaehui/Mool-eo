//
//  SettingInfoTableViewCell.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/12/24.
//

import UIKit
import SnapKit

class SettingInfoTableViewCell: BaseTableViewCell {
    
    let userInfoLabel: CustomLabel = {
        let label = CustomLabel(type: .contentBold)
        label.text = "회원 정보"
        return label
    }()
    
    let idStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .leading
        stackView.spacing = 15
        return stackView
    }()
    
    let idInfoLabel: CustomLabel = {
        let label = CustomLabel(type: .content)
        label.text = "아이디"
        return label
    }()
    
    let idLabel: CustomLabel = {
        let label = CustomLabel(type: .subContent)
        return label
    }()
    
    let nicknameStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .leading
        stackView.spacing = 15
        return stackView
    }()
    
    let nicknameInfoLabel: CustomLabel = {
        let label = CustomLabel(type: .content)
        label.text = "닉네임"
        return label
    }()
    
    let nicknameLabel: CustomLabel = {
        let label = CustomLabel(type: .subContent)
        return label
    }()
    
    override func configureHierarchy() {
        contentView.addSubview(userInfoLabel)
        contentView.addSubview(idStackView)
        idStackView.addArrangedSubview(idInfoLabel)
        idStackView.addArrangedSubview(idLabel)
        contentView.addSubview(nicknameStackView)
        nicknameStackView.addArrangedSubview(nicknameInfoLabel)
        nicknameStackView.addArrangedSubview(nicknameLabel)
    }
    
    override func configureConstraints() {
        userInfoLabel.snp.makeConstraints { make in
            make.top.equalTo(contentView).inset(10)
            make.horizontalEdges.equalTo(contentView).inset(20)
        }
        
        idStackView.snp.makeConstraints { make in
            make.top.equalTo(userInfoLabel.snp.bottom).offset(10)
            make.horizontalEdges.equalTo(contentView).inset(20)
        }
        
        nicknameStackView.snp.makeConstraints { make in
            make.top.equalTo(idStackView.snp.bottom).offset(10)
            make.horizontalEdges.equalTo(contentView).inset(20)
            make.bottom.lessThanOrEqualTo(contentView).inset(10)
        }
    }
    
    func configureCell(_ profile: ProfileModel) {
        idLabel.text = profile.email
        nicknameLabel.text = profile.nick
    }
}
