//
//  ProductTextFieldView.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/10/24.
//

import UIKit
import SnapKit

class ProductTextFieldView: BaseView {
    let customLabel: CustomLabel
    let customTextField: CustomTextField
    let textFieldType: TextFieldType
    
    init(frame: CGRect, textFieldType: TextFieldType) {
        self.textFieldType = textFieldType
        self.customLabel = CustomLabel(type: .colorContentBold)
        self.customLabel.text = textFieldType.rawValue
        self.customTextField = CustomTextField(type: textFieldType)
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func configureHierarchy() {
        addSubview(customLabel)
        addSubview(customTextField)
    }
    
    override func configureConstraints() {
        customLabel.snp.makeConstraints { make in
            make.top.horizontalEdges.equalTo(safeAreaLayoutGuide)
            make.height.equalTo(20)
        }
        
        customTextField.snp.makeConstraints { make in
            make.top.equalTo(customLabel.snp.bottom).offset(5)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide)
            make.height.equalTo(40)
            make.bottom.equalTo(safeAreaLayoutGuide)
        }
    }
}
