//
//  JoinThirdViewController.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/19/24.
//

import UIKit
import RxSwift
import RxCocoa

class JoinThirdViewController: BaseViewController {
    
    let disposeBag = DisposeBag()
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
        output.nicknameValidation.drive(with: self) { owner, value in
            owner.joinThirdView.nicknameView.descriptionLabel.textColor = value ? ColorStyle.subText : ColorStyle.caution
            owner.joinThirdView.nicknameView.descriptionLabel.text = value ? nil : TextFieldType.nickname.description
        }.disposed(by: disposeBag)
        
        output.joinButtonValidation.drive(joinThirdView.joinButton.rx.isEnabled).disposed(by: disposeBag)
        
        output.joinSuccessTrigger.bind(with: self) { owner, _ in
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            let sceneDelegate = windowScene?.delegate as? SceneDelegate
            sceneDelegate?.window?.rootViewController = UINavigationController(rootViewController: LoginViewController())
            sceneDelegate?.window?.makeKeyAndVisible()
        }.disposed(by: disposeBag)
    }
}
