//
//  JoinThirdViewController.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/19/24.
//

import UIKit
import RxSwift
import RxCocoa

// 회원가입 세번째 로직 : 닉네임 입력
class JoinThirdViewController: BaseViewController {
    
    deinit {
        print("‼️JoinThirdViewController Deinit‼️")
    }
    
    let viewModel = JoinThirdViewModel()
    let joinThirdView = JoinThirdView()
    
    var id: String = ""
    var password: String = ""
    
    override func loadView() {
        self.view = joinThirdView
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func bind() {
        let id = Observable.just(id)
        let password = Observable.just(password)
        let nickname = joinThirdView.nicknameView.customTextField.rx.text.orEmpty.asObservable()
        let joinButtonTap = joinThirdView.joinButton.rx.tap.asObservable()
        let input = JoinThirdViewModel.Input(id: id, password: password, nickname: nickname, joinButtonTap: joinButtonTap)
        
        let output = viewModel.transform(input: input)
        
        // 닉네임 기본 조건
        output.nicknameValidation.drive(with: self) { owner, value in
            owner.joinThirdView.nicknameView.descriptionLabel.textColor = value ? ColorStyle.available : ColorStyle.caution
            owner.joinThirdView.nicknameView.descriptionLabel.text = value ? "사용 가능한 닉네임입니다." : TextFieldType.nickname.description
        }.disposed(by: disposeBag)
        
        output.joinButtonValidation.drive(joinThirdView.joinButton.rx.isEnabled).disposed(by: disposeBag)
        
        // 회원가입 네트워크 통신 성공 -> 앱의 첫 화면을 변경 (회원가입 화면이 계속 남아있지 않도록)
        output.joinSuccessTrigger.drive(with: self) { owner, _ in
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            let sceneDelegate = windowScene?.delegate as? SceneDelegate
            sceneDelegate?.window?.rootViewController = UINavigationController(rootViewController: LoginViewController())
            sceneDelegate?.window?.makeKeyAndVisible()
        }.disposed(by: disposeBag)
    }
}
