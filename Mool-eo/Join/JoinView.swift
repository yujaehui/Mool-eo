//
//  JoinView.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/13/24.
//

import UIKit
import SnapKit

class JoinView: BaseView {
    
    let titleLabel: CustomLabel = {
        let label = CustomLabel(type: .colorTitleBold)
        label.text = "STEP 1\n사용하실 이메일과 비밀번호를 입력해주세요."
        label.numberOfLines = 2
        return label
    }()
    
    let idView: JoinTextFieldView = {
        let view = JoinTextFieldView(frame: .zero, textFieldType: .id)
        return view
    }()
    
    let idCheckButton: UIButton = {
        let button = UIButton()
        button.configuration = .check2("중복확인")
        return button
    }()
    
    let passwordView: JoinTextFieldView = {
        let view = JoinTextFieldView(frame: .zero, textFieldType: .password)
        return view
    }()
    
    let nextButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "arrow.right"), for: .normal)
        button.tintColor = ColorStyle.point
        button.backgroundColor = ColorStyle.subBackground
        button.frame = .init(x: 0, y: 0, width: 40, height: 40)
        button.clipsToBounds = true
        button.layer.cornerRadius = 20
        return button
    }()

    override func configureHierarchy() {
        addSubview(titleLabel)
        addSubview(idView)
        addSubview(idCheckButton)
        addSubview(passwordView)
        addSubview(nextButton)
    }
    
    override func configureConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).inset(20)
            make.leading.equalTo(safeAreaLayoutGuide).inset(20)
        }
        
        idView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(40)
            make.leading.equalTo(safeAreaLayoutGuide).inset(20)
        }
        
        idCheckButton.snp.makeConstraints { make in
            make.centerY.equalTo(idView.snp.centerY)
            make.leading.equalTo(idView.snp.trailing).offset(10)
            make.trailing.equalTo(safeAreaLayoutGuide).inset(20)
            make.height.equalTo(40)
            make.width.equalTo(80)
        }
        
        passwordView.snp.makeConstraints { make in
            make.top.equalTo(idView.snp.bottom).offset(20)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(20)
        }
        
        nextButton.snp.makeConstraints { make in
            make.top.equalTo(passwordView.snp.bottom).offset(20)
            make.trailing.equalTo(safeAreaLayoutGuide).inset(20)
            make.size.equalTo(40)
        }
    }
}
