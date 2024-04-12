//
//  LoginView.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/12/24.
//

import UIKit
import SnapKit

class LoginView: BaseView {
    
    let loginBoxView: LoginBoxView = {
        let view = LoginBoxView()
        return view
    }()
    
    let joinLabel: CustomLabel = {
        let label = CustomLabel(type: .subDescription)
        label.text = "회원이 아니신가요?"
        return label
    }()
    
    let joinButton: UIButton = {
        let button = UIButton()
        button.configuration = .text("회원가입")
        return button
    }()
    
    override func configureHierarchy() {
        addSubview(loginBoxView)
        addSubview(joinLabel)
        addSubview(joinButton)
    }
    
    override func configureConstraints() {
        loginBoxView.snp.makeConstraints { make in
            make.centerX.equalTo(safeAreaLayoutGuide)
            make.centerY.equalTo(safeAreaLayoutGuide).offset(-50)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide)
        }
        
        joinLabel.snp.makeConstraints { make in
            make.centerX.equalTo(safeAreaLayoutGuide)
        }
        
        joinButton.snp.makeConstraints { make in
            make.top.equalTo(joinLabel.snp.bottom)
            make.centerX.equalTo(safeAreaLayoutGuide)
            make.bottom.equalTo(safeAreaLayoutGuide).inset(10)
        }
    }
}
