//
//  CommentTextFieldView.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/23/24.
//

import UIKit
import SnapKit

class CommentTextFieldView: BaseView {
    let commentTextField: UITextField = {
       let textField = UITextField()
        textField.addLeftPadding()
        textField.placeholder = "댓글을 입력하세요"
        textField.backgroundColor = ColorStyle.subBackground
        return textField
    }()
    
    override func configureHierarchy() {
        addSubview(commentTextField)
    }
    
    override func configureConstraints() {
        commentTextField.snp.makeConstraints { make in
            make.verticalEdges.equalTo(safeAreaLayoutGuide).inset(10)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(20)
        }
    }

}
