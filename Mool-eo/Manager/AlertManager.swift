//
//  AlertManager.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 7/11/24.
//

import UIKit

final class AlertManager {
    static let shared = AlertManager()
    private init() {}
    
    func showWithdrawAlert(hadler: ((UIAlertAction) -> Void)? ) -> UIAlertController {
        let alert = UIAlertController(title: "회원 탈퇴", message: "이 작업은 되돌릴 수 없습니다.\n계속해서 탈퇴를 진행하시겠습니까?", preferredStyle: .alert)
        let cancelButton = UIAlertAction(title: "취소", style: .cancel)
        let withdrawButton = UIAlertAction(title: "탈퇴", style: .destructive, handler: hadler)
        alert.addAction(cancelButton)
        alert.addAction(withdrawButton)
        return alert
    }
}
