//
//  LoginBoxView.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/12/24.
//

import UIKit
import SnapKit

final class LoginBoxView: BaseView {
    let logoImageView: PostImageView = {
        let imageView = PostImageView(frame: .zero)
        imageView.image = .logo.downsample(to: .medium)
        imageView.tintColor = ColorStyle.point
        return imageView
    }()
    
    let idTextField = CustomTextField(type: .id)
    
    let passwordTextField: CustomTextField = {
        let textField = CustomTextField(type: .password)
        textField.textContentType = .password
        textField.isSecureTextEntry = true
        return textField
    }()
    
    let loginButton: UIButton = {
        let button = UIButton()
        button.configuration = .check("로그인")
        return button
    }()
    
    override func configureHierarchy() {
        addSubview(logoImageView)
        addSubview(idTextField)
        addSubview(passwordTextField)
        addSubview(loginButton)
    }
    
    override func configureConstraints() {
        logoImageView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide)
            make.centerX.equalTo(safeAreaLayoutGuide)
            make.size.equalTo(100)
        }
        
        idTextField.snp.makeConstraints { make in
            make.top.equalTo(logoImageView.snp.bottom).offset(30)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(20)
            make.height.equalTo(40)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(idTextField.snp.bottom).offset(20)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(20)
            make.height.equalTo(40)
        }
        
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(30)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(20)
            make.height.equalTo(40)
            make.bottom.equalTo(safeAreaLayoutGuide).inset(10)
        }
    }
}
