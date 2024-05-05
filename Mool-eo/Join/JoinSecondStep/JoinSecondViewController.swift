//
//  JoinSecondViewController.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/13/24.
//

import UIKit
import RxSwift
import RxCocoa

// 회원가입 두번째 로직 : 비밀번호 입력
class JoinSecondViewController: BaseViewController {
    
    deinit {
        print("‼️JoinSecondViewController Deinit‼️")
    }
    
    let viewModel = JoinSecondViewModel()
    let joinSecondView = JoinSecondView()
    
    var id: String = ""
    
    override func loadView() {
        self.view = joinSecondView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func bind() {
        let password = joinSecondView.passwordView.customTextField.rx.text.orEmpty.asObservable()
        let nextButtonTap = joinSecondView.nextButton.rx.tap.asObservable()
        let input = JoinSecondViewModel.Input(password: password, nextButtonTap: nextButtonTap)
        
        let output = viewModel.transform(input: input)
        
        // 비밀번호 기본 조건
        output.passwordValidation.drive(with: self) { owner, value in
            owner.joinSecondView.passwordView.descriptionLabel.textColor = value ? ColorStyle.available : ColorStyle.caution
            owner.joinSecondView.passwordView.descriptionLabel.text = value ? "사용 가능한 비밀번호입니다." : TextFieldType.password.description
        }.disposed(by: disposeBag)
        
        output.nextButtonValidation.drive(joinSecondView.nextButton.rx.isEnabled).disposed(by: disposeBag)
        
        // 다음 버튼을 클릭했을 경우, 회원가입 세번째 로직으로 이동
        output.nextButtonTap.drive(with: self) { owner, _ in
            let vc = JoinThirdViewController()
            vc.id = owner.id
            vc.password = owner.joinSecondView.passwordView.customTextField.text ?? ""
            owner.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: disposeBag)

    }
}
