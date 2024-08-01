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
import IQKeyboardManagerSwift

final class LoginViewController: BaseViewController {
    
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
        IQKeyboardManager.shared.keyboardDistanceFromTextField = 0
    }
    
    override func bind() {
        let input = LoginViewModel.Input(
            keyboardWillShow: NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification),
            keyboardWillHide: NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification),
            id: loginView.loginBoxView.idTextField.rx.text.orEmpty.asObservable(),
            password: loginView.loginBoxView.passwordTextField.rx.text.orEmpty.asObservable(),
            loginButtonTap: loginView.loginBoxView.loginButton.rx.tap.asObservable(),
            joinButtonTap: loginView.joinButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.keyboardWillShow.bind(with: self) { owner, notification in
            owner.keyboardWillShow(notification: notification)
        }.disposed(by: disposeBag)
        
        output.keyboardWillHide.bind(with: self) { owner, notification in
            owner.keyboardWillHide(notification: notification)
        }.disposed(by: disposeBag)
        
        output.loginValidation.drive(with: self) { owner, value in
            owner.loginView.loginBoxView.loginButton.isEnabled = value
        }.disposed(by: disposeBag)
        
        output.loginSuccessTrigger.drive(with: self) { owner, _ in
            TransitionManager.shared.setInitialViewController(ViewController(), navigation: false)
        }.disposed(by: disposeBag)
        
        output.joinButtonTap.drive(with: self) { owner, _ in
            owner.navigationController?.pushViewController(JoinViewController(), animated: true)
        }.disposed(by: disposeBag)
        
        output.authenticationErr.drive(with: self) { owner, _ in
            ToastManager.shared.showErrorToast(title: .authenticationErr, in: owner.loginView)
        }.disposed(by: disposeBag)
        
        output.badRequest.drive(with: self) { owner, _ in
            ToastManager.shared.showErrorToast(title: .badRequestLogin, in: owner.loginView)
        }.disposed(by: disposeBag)
        
        output.networkFail.drive(with: self) { owner, _ in
            ToastManager.shared.showErrorToast(title: .networkFail, in: owner.loginView)
        }.disposed(by: disposeBag)
    }
    
    private func keyboardWillShow(notification: Notification) {
        guard let userInfo = notification.userInfo, let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
        let keyboardHeight = keyboardFrame.height
        
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            self.loginView.loginBoxView.snp.updateConstraints { make in
                make.centerY.equalTo(self.loginView.safeAreaLayoutGuide).offset(-keyboardHeight / 2)
            }
            self.view.layoutIfNeeded()
        }
    }
    
    private func keyboardWillHide(notification: Notification) {
        UIView.animate(withDuration: 0.3) { [weak self] in
            guard let self = self else { return }
            self.loginView.loginBoxView.snp.updateConstraints { make in
                make.centerY.equalTo(self.loginView.safeAreaLayoutGuide).offset(-50)
            }
            self.view.layoutIfNeeded()
        }
    }
}
