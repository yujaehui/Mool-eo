//
//  ProfileEditView.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/18/24.
//

import UIKit
import SnapKit

class ProfileEditView: BaseView {
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = ColorStyle.point
        imageView.backgroundColor = ColorStyle.subBackground
        imageView.frame = .init(x: 0, y: 0, width: 100, height: 100)
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 50
        return imageView
    }()
    
    let profileImageEditButton: UIButton = {
       let button = UIButton()
        button.configuration = .capsule("수정")
        return button
    }()
    
    let nameLabel: CustomLabel = {
        let label = CustomLabel(type: .description)
        label.text = TextFieldType.nickname.rawValue
        return label
    }()
    
    let nameTextField: CustomTextField = {
        let textField = CustomTextField(type: .nickname)
        return textField
    }()
    
    let birthdayLabel: CustomLabel = {
        let label = CustomLabel(type: .description)
        label.text = TextFieldType.birthday.rawValue
        return label
    }()
    
    let birthdayTextField: CustomTextField = {
        let textField = CustomTextField(type: .birthday)
        return textField
    }()
    
    override func configureHierarchy() {
        addSubview(profileImageView)
        addSubview(profileImageEditButton)
        addSubview(nameLabel)
        addSubview(nameTextField)
        addSubview(birthdayLabel)
        addSubview(birthdayTextField)
    }
    
    override func configureConstraints() {
        profileImageView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).inset(10)
            make.centerX.equalTo(safeAreaLayoutGuide)
            make.size.equalTo(100)
        }
        
        profileImageEditButton.snp.makeConstraints { make in
            make.top.equalTo(profileImageView.snp.bottom).offset(10)
            make.centerX.equalTo(safeAreaLayoutGuide)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(profileImageEditButton.snp.bottom).offset(40)
            make.leading.equalTo(safeAreaLayoutGuide).inset(20)
        }
        
        nameTextField.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(5)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(20)
        }
        
        birthdayLabel.snp.makeConstraints { make in
            make.top.equalTo(nameTextField.snp.bottom).offset(20)
            make.leading.equalTo(safeAreaLayoutGuide).inset(20)
        }
        
        birthdayTextField.snp.makeConstraints { make in
            make.top.equalTo(birthdayLabel.snp.bottom).offset(5)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(20)
        }
    }
}
