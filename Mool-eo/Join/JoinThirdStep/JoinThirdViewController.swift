//
//  JoinThirdViewController.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/19/24.
//

import UIKit
import RxSwift
import RxCocoa
import Toast

final class JoinThirdViewController: BaseViewController {
    
    deinit { print("‼️JoinThirdViewController Deinit‼️") }
    
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
        let input = JoinThirdViewModel.Input(
            id: Observable.just(id),
            password: Observable.just(password),
            nickname: joinThirdView.nicknameView.customTextField.rx.text.orEmpty.asObservable(),
            joinButtonTap: joinThirdView.joinButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.nicknameValidation.drive(with: self) { owner, value in
            owner.joinThirdView.nicknameView.descriptionLabel.textColor = value ? ColorStyle.available : ColorStyle.caution
            owner.joinThirdView.nicknameView.descriptionLabel.text = value ? "사용 가능한 닉네임입니다." : TextFieldType.nickname.description
        }.disposed(by: disposeBag)
        
        output.joinButtonValidation.drive(joinThirdView.joinButton.rx.isEnabled).disposed(by: disposeBag)
        
        output.joinSuccessTrigger.drive(with: self) { owner, value in
            let vc = JoinSuccessViewController()
            vc.id = value.email
            vc.nickname = value.nick
            owner.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: disposeBag)
        
        output.networkFail.drive(with: self) { owner, _ in
            ToastManager.shared.showErrorToast(title: .networkFail, in: owner.joinThirdView)
        }.disposed(by: disposeBag)
    }
}
