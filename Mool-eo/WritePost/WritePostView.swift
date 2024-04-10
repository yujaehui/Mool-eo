//
//  WritePostView.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/10/24.
//

import UIKit

class WritePostView: BaseView {
    
    let titleTextField: UITextField = {
       let textField = UITextField()
        textField.addLeftPadding()
        textField.font = FontStyle.titleBold
        textField.placeholder = "제목"
        return textField
    }()
    
    let lineView = LineView()
    
    let contentTextView: UITextView = {
       let textView = UITextView()
        textView.font = FontStyle.content
        return textView
    }()

    override func configureHierarchy() {
        addSubview(titleTextField)
        addSubview(lineView)
        addSubview(contentTextView)
    }
    
    override func configureConstraints() {
        titleTextField.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(20)
            make.height.equalTo(44)
        }
        
        lineView.snp.makeConstraints { make in
            make.top.equalTo(titleTextField.snp.bottom)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(20)
            make.height.equalTo(1)
        }
        
        contentTextView.snp.makeConstraints { make in
            make.top.equalTo(lineView.snp.bottom).offset(10)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(20)
            make.bottom.equalTo(safeAreaLayoutGuide)
        }
    }

}
