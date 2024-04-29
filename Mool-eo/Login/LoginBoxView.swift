//
//  LoginBoxView.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/12/24.
//

import UIKit
import SnapKit


// 키보드가 올라옴에 따라서 해당 화면 자체의 constraints가 변경될 것.
class LoginBoxView: BaseView {
    let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "dog.circle.fill")
        imageView.tintColor = ColorStyle.point
        return imageView
    }()
    
    let idTextField: CustomTextField = {
        let textField = CustomTextField(type: .id)
        return textField
    }()
    
    let passwordTextField: CustomTextField = {
        let textField = CustomTextField(type: .password)
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
