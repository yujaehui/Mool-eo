//
//  CustomTextFieldView.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/13/24.
//

import UIKit
import SnapKit

class CustomTextFieldView: BaseView {
    let customLabel: CustomLabel
    let customTextField: CustomTextField
    let textFieldType: TextFieldType
    let descriptionLabel: CustomLabel
    
    init(frame: CGRect, textFieldType: TextFieldType) {
        self.textFieldType = textFieldType
        self.customLabel = CustomLabel(type: .colorContentBold)
        self.customLabel.text = textFieldType.rawValue
        self.customTextField = CustomTextField(type: textFieldType)
        self.descriptionLabel = CustomLabel(type: .subDescription)
        self.descriptionLabel.text = textFieldType.description
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func configureHierarchy() {
        addSubview(customLabel)
        addSubview(customTextField)
        addSubview(descriptionLabel)
    }
    
    override func configureConstraints() {
        customLabel.snp.makeConstraints { make in
            make.top.leading.equalTo(safeAreaLayoutGuide)
            make.height.equalTo(20)
        }
        
        customTextField.snp.makeConstraints { make in
            make.top.equalTo(customLabel.snp.bottom).offset(5)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide)
            make.height.equalTo(40)
        }
        
        descriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(customTextField.snp.bottom).offset(5)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide)
            make.bottom.equalTo(safeAreaLayoutGuide)
            make.height.equalTo(20)
        }
    }
}
