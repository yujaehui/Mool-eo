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
    case conflict = "이미 가입된 회원입니다"
    case forbidden = "권한이 없습니다"
    case badRequest = "잘못된 요청입니다"
    case notFoundErr = "찾을 수 없습니다"
    case unauthorized = "삭제 또는 수정 권한이 없습니다"
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
