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
    case nickname = "반려동물 이름"
    case birthday = "반려동물 생년월일"
    
    var description: String {
        switch self {
        case .id: "4~12자/영문 소문자(숫자 조합 가능)"
        case .password: "6~20자/영문 소문자, 숫자 조합"
        case .nickname: "예) 리치 / 리치, 소금이 / 리치-소금이-콩이"
        case .birthday: ""
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

