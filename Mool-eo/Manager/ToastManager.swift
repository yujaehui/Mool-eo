//
//  ToastManager.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/5/24.
//

import Foundation
import UIKit
import Toast

enum ErrorToastTitle: String {
    case networkFail = "네트워크 연결이 원할하지 않습니다"
    case authenticationErr = "아이디 또는 비밀번호가 일치하지 않습니다"
    case badRequestLogin = "제대로 된 값을 입력해주세요"
    case badRequestImageUpload = "이미지의 용량이 너무 큽니다"
    case notFoundErrPostUpload = "DB 서버 장애로 인해\n게시글 작성에 오류가 발생했습니다"
    case notFoundErrFollow = "해당 유저를 찾을 수 없습니다"
}

class ToastManager {
    static let shared = ToastManager()
    
    private init() {}
    
    func showToast(title: String, in view: UIView) {
        var style = ToastStyle()
        style.backgroundColor = ColorStyle.point
        style.messageAlignment = .center
        view.makeToast(title, duration: 2, position: .top, style: style)
    }
    
    func showErrorToast(title: ErrorToastTitle, in view: UIView) {
        var style = ToastStyle()
        style.backgroundColor = ColorStyle.point
        style.messageAlignment = .center
        view.makeToast(title.rawValue, duration: 2, position: .top, style: style)
    }
}
