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
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20
        return imageView
    }()
    
    let profileImageEditButton: UIButton = {
        let button = UIButton()
        button.configuration = .text("프로필 이미지 수정")
        return button
    }()
    
    let nicknameView: CustomTextFieldView = {
        let view = CustomTextFieldView(frame: .zero, textFieldType: .nickname)
        return view
    }()
    
    
    let introductionView: CustomTextFieldView = {
        let view = CustomTextFieldView(frame: .zero, textFieldType: .introduction)
        return view
    }()
    
    
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
