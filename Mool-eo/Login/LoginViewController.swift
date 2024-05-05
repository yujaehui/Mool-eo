//
//  LoginViewController.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/12/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa
import Toast

class LoginViewController: BaseViewController {
    
    deinit {
        print("‼️LoginViewController Deinit‼️")
    }
    
    let viewModel = LoginViewModel()
    let loginView = LoginView()
    
    override func loadView() {
        self.view = loginView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true) // 화면 터치시 키보드 내려가도록
    }
    
    override func setNav() {
        navigationItem.backButtonTitle = ""
        navigationController?.navigationBar.tintColor = ColorStyle.point
    }
    
    override func bind() {
        let keyboardWillShow = NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification) // 키보드가 나타나는 시점
        let keyboardWillHide = NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification) // 키보드가 사라지는 시점
        let id = loginView.loginBoxView.idTextField.rx.text.orEmpty.asObservable()
        let password = loginView.loginBoxView.passwordTextField.rx.text.orEmpty.asObservable()
        let loginButtonTap = loginView.loginBoxView.loginButton.rx.tap.asObservable()
        let joinButtonTap = loginView.joinButton.rx.tap.asObservable()
        let input = LoginViewModel.Input(keyboardWillShow: keyboardWillShow, keyboardWillHide: keyboardWillHide, id: id, password: password, loginButtonTap: loginButtonTap, joinButtonTap: joinButtonTap)
        
        let output = viewModel.transform(input: input)
        
        // 키보드가 나타났을 경우
        output.keyboardWillShow.bind(with: self) { owner, notification in
            owner.keyboardWillShow(notification: notification)
        }.disposed(by: disposeBag)
        
        // 키보드가 사라졌을 경우
        output.keyboardWillHide.bind(with: self) { owner, notification in
            owner.keyboardWillHide(notification: notification)
        }.disposed(by: disposeBag)
        
        output.loginValidation.drive(loginView.loginBoxView.loginButton.rx.isEnabled).disposed(by: disposeBag)
        
        // 로그인 네트워크 통신 성공 -> 앱의 첫 화면을 변경 (로그인 화면이 계속 남아있지 않도록)
        output.loginSuccessTrigger.drive(with: self) { owner, _ in
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            let sceneDelegate = windowScene?.delegate as? SceneDelegate
            sceneDelegate?.window?.rootViewController = ViewController()
            sceneDelegate?.window?.makeKeyAndVisible()
        }.disposed(by: disposeBag)
        
        // 회원가입 버튼을 클릭했을 경우, 회원가입 화면으로 이동
        output.joinButtonTap.drive(with: self) { owner, _ in
            print("...")
            owner.navigationController?.pushViewController(JoinViewController(), animated: true)
        }.disposed(by: disposeBag)
        
        output.authenticationErr.drive(with: self) { owner, _ in
            ToastManager.shared.showErrorToast(title: .authenticationErr, in: owner.loginView)
        }.disposed(by: disposeBag)
        
        output.badRequest.drive(with: self) { owner, _ in
            ToastManager.shared.showErrorToast(title: .badRequest, in: owner.loginView)
        }.disposed(by: disposeBag)
        
        output.networkFail.drive(with: self) { owner, _ in
            ToastManager.shared.showErrorToast(title: .networkFail, in: owner.loginView)
        }.disposed(by: disposeBag)
    }
    
    // 키보드가 나타났을 경우 loginBoxView의 위치 조정
    private func keyboardWillShow(notification: Notification) {
        guard let userInfo = notification.userInfo, let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let keyboardHeight = keyboardFrame.height
        
        UIView.animate(withDuration: 0.3) {
            self.loginView.loginBoxView.snp.updateConstraints { make in
                make.centerY.equalTo(self.loginView.safeAreaLayoutGuide).offset(-keyboardHeight / 2)
            }
            self.view.layoutIfNeeded()
        }
    }
    
    // 키보드가 사라졌을 경우 loginBoxView의 위치 조정 (초기 위치와 동일하게 설정)
    private func keyboardWillHide(notification: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.loginView.loginBoxView.snp.updateConstraints { make in
                make.centerY.equalTo(self.loginView.safeAreaLayoutGuide).offset(-50)
            }
            self.view.layoutIfNeeded()
        }
    }
}
