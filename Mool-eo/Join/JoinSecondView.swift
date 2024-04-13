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
        label.text = "STEP 2\n사랑하는 반려동물의 정보를 입력해주세요."
        label.numberOfLines = 2
        return label
    }()

    let nicknameView: JoinTextFieldView = {
        let view = JoinTextFieldView(frame: .zero, textFieldType: .nickname)
        return view
    }()
    
    let datePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.datePickerMode = .date
        datePicker.locale = Locale(identifier: "Korean")
        return datePicker
    }()
    
    lazy var birthdayView: JoinTextFieldView = {
        let view = JoinTextFieldView(frame: .zero, textFieldType: .birthday)
        view.customTextField.inputView = datePicker
        return view
    }()
    
    let joinButton: UIButton = {
        let button = UIButton()
        button.configuration = .check("회원가입")
        return button
    }()
    
    override func configureHierarchy() {
        addSubview(titleLabel)
        addSubview(nicknameView)
        addSubview(birthdayView)
        addSubview(joinButton)
    }
    
    override func configureConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).inset(20)
            make.leading.equalTo(safeAreaLayoutGuide).inset(20)
        }
        
        nicknameView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(40)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(20)
        }
        
        birthdayView.snp.makeConstraints { make in
            make.top.equalTo(nicknameView.snp.bottom).offset(20)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(20)
        }
        
        joinButton.snp.makeConstraints { make in
            make.top.equalTo(birthdayView.snp.bottom).offset(20)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(20)
            make.height.equalTo(40)
        }
    }
}
