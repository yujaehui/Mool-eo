//
//  CustomTextField.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/13/24.
//

import UIKit

enum TextFieldType: String {
    case id = "아이디"
    case password = "비밀번호"
    case nickname = "닉네임"
    case introduction = "한줄소개"
    
    var description: String {
        switch self {
        case .id: "4~12자/공백 X, 영문 소문자, 숫자"
        case .password: "4~12자/공백 X, 영문 소문자, 숫자"
        case .nickname: "2~10자/공백 없이 입력해주세요."
        case .introduction: "15자 이내로 자신을 표현해보세요."
        }
    }
}

class CustomTextField: UITextField {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    convenience init(type: TextFieldType) {
        self.init(frame: .zero)
        configureView(type)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureView(_ type: TextFieldType) {
        self.placeholder = type.rawValue
        self.borderStyle = .roundedRect
    }
}
