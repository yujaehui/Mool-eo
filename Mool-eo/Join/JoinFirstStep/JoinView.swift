//
//  JoinView.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/13/24.
//

import UIKit
import SnapKit

final class JoinView: BaseView {
    
    let titleLabel: CustomLabel = {
        let label = CustomLabel(type: .colorTitleBold)
        label.text = "STEP 1\n아이디를 입력해주세요."
        label.numberOfLines = 2
        return label
    }()
    
    let idView = ProfileTextFieldView(frame: .zero, textFieldType: .id)
    
    let idCheckButton: UIButton = {
        let button = UIButton()
        button.configuration = .check("중복확인")
        return button
    }()
    
    let nextButton: UIButton = {
        let button = UIButton()
        button.configuration = .check("다음")
        return button
    }()

    override func configureHierarchy() {
        addSubview(titleLabel)
        addSubview(idView)
        addSubview(idCheckButton)
        addSubview(nextButton)
    }
    
    override func configureConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).inset(20)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(20)
        }
        
        idView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
            make.leading.equalTo(safeAreaLayoutGuide).inset(20)
        }
        
        idCheckButton.snp.makeConstraints { make in
            make.centerY.equalTo(idView.snp.centerY)
            make.leading.equalTo(idView.snp.trailing).offset(10)
            make.trailing.equalTo(safeAreaLayoutGuide).inset(20)
            make.height.equalTo(40)
            make.width.equalTo(80)
        }
        
        nextButton.snp.makeConstraints { make in
            make.top.equalTo(idView.snp.bottom).offset(20)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(20)
            make.height.equalTo(40)
        }
    }
}
