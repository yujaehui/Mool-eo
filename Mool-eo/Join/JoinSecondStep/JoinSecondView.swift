//
//  JoinSecondView.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/13/24.
//

import UIKit
import SnapKit

class JoinSecondView: BaseView {
    
    let titleLabel: CustomLabel = {
        let label = CustomLabel(type: .colorTitleBold)
        label.text = "STEP 2\n비밀번호를 입력해주세요."
        label.numberOfLines = 2
        return label
    }()

    let passwordView: CustomTextFieldView = {
        let view = CustomTextFieldView(frame: .zero, textFieldType: .password)
        view.customTextField.textContentType = .password
        view.customTextField.isSecureTextEntry = true
        return view
    }()
    
    let nextButton: UIButton = {
        let button = UIButton()
        button.configuration = .check("다음")
        return button
    }()
    
    override func configureHierarchy() {
        addSubview(titleLabel)
        addSubview(passwordView)
        addSubview(nextButton)
    }
    
    override func configureConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).inset(20)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(20)
        }
        
        passwordView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(20)
        }
        
        nextButton.snp.makeConstraints { make in
            make.top.equalTo(passwordView.snp.bottom).offset(20)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(20)
            make.height.equalTo(40)
        }
    }
}
