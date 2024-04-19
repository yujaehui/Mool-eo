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

class LoginViewController: BaseViewController {
    
    let disposeBag = DisposeBag()
    let viewModel = LoginViewModel()
    let loginView = LoginView()
    
    override func loadView() {
        self.view = loginView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    override func bind() {
        let keyboardWillShow = NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification)
        let keyboardWillHide = NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification)
        let joinButtonTap = loginView.joinButton.rx.tap.asObservable()
        let id = loginView.loginBoxView.idTextField.rx.text.orEmpty.asObservable()
        let password = loginView.loginBoxView.passwordTextField.rx.text.orEmpty.asObservable()
        let loginButtonTap = loginView.loginBoxView.loginButton.rx.tap.asObservable()
        let input = LoginViewModel.Input(keyboardWillShow: keyboardWillShow, keyboardWillHide: keyboardWillHide, joinButtonTap: joinButtonTap, id: id, password: password, loginButtonTap: loginButtonTap)
        
        let output = viewModel.transform(input: input)
        
        output.keyboardWillShow.bind(with: self) { owner, notification in
            owner.keyboardWillShow(notification: notification)
        }.disposed(by: disposeBag)
        
        output.keyboardWillHide.bind(with: self) { owner, notification in
            owner.keyboardWillHide(notification: notification)
        }.disposed(by: disposeBag)
        
        output.joinButtonTap.bind(with: self) { owner, _ in
            owner.navigationController?.pushViewController(JoinViewController(), animated: true)
        }.disposed(by: disposeBag)
        
        output.loginValidation.drive(loginView.loginBoxView.loginButton.rx.isEnabled).disposed(by: disposeBag)
        
        output.loginSuccessTrigger.drive(with: self) { owner, _ in
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            let sceneDelegate = windowScene?.delegate as? SceneDelegate
            sceneDelegate?.window?.rootViewController = UINavigationController(rootViewController: PostBoardViewController())
            sceneDelegate?.window?.makeKeyAndVisible()
        }.disposed(by: disposeBag)
    }
    
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
    
    private func keyboardWillHide(notification: Notification) {
        UIView.animate(withDuration: 0.3) {
            self.loginView.loginBoxView.snp.updateConstraints { make in
                make.centerY.equalTo(self.loginView.safeAreaLayoutGuide).offset(-50)
            }
            self.view.layoutIfNeeded()
        }
    }
}
