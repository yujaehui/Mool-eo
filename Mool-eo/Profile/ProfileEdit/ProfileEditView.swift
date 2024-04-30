//
//  ProfileEditView.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/18/24.
//

import UIKit
import SnapKit

class ProfileEditView: BaseView {
    // Navigation
    let completeButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.title = "완료"
        return button
    }()
    
    // Navigation
    let cancelButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.image = UIImage(systemName: "xmark")
        return button
    }()
    
    let profileImageView = CustomImageView(frame: .zero)
    
    let profileImageEditButton: UIButton = {
        let button = UIButton()
        button.configuration = .text("프로필 이미지 수정")
        return button
    }()
    
    let nicknameView = CustomTextFieldView(frame: .zero, textFieldType: .nickname)
    
    let introductionView = CustomTextFieldView(frame: .zero, textFieldType: .introduction)
    
    
    override func configureHierarchy() {
        addSubview(profileImageView)
        addSubview(profileImageEditButton)
        addSubview(nicknameView)
        addSubview(introductionView)
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
        
        nicknameView.snp.makeConstraints { make in
            make.top.equalTo(profileImageEditButton.snp.bottom).offset(20)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(20)
        }
        
        introductionView.snp.makeConstraints { make in
            make.top.equalTo(nicknameView.snp.bottom).offset(10)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(20)
        }
    }
}
