//
//  JoinThirdView.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/19/24.
//

import UIKit
import SnapKit

final class JoinThirdView: BaseView {
    let titleLabel: CustomLabel = {
        let label = CustomLabel(type: .colorTitleBold)
        label.text = "STEP 3\n사용하실 닉네임을 입력해주세요."
        label.numberOfLines = 2
        return label
    }()
    
    let nicknameView = ProfileTextFieldView(frame: .zero, textFieldType: .nickname)
    
    let joinButton: UIButton = {
        let button = UIButton()
        button.configuration = .check("회원가입")
        return button
    }()
    
    override func configureHierarchy() {
        addSubview(titleLabel)
        addSubview(nicknameView)
        addSubview(joinButton)
    }
    
    override func configureConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).inset(20)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(20)
        }
        
        nicknameView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(20)
        }
        
        joinButton.snp.makeConstraints { make in
            make.top.equalTo(nicknameView.snp.bottom).offset(20)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(20)
            make.height.equalTo(40)
        }
    }
}
