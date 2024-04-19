//
//  JoinSecondViewController.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/13/24.
//

import UIKit
import RxSwift
import RxCocoa

class JoinSecondViewController: BaseViewController {
    
    let disposeBag = DisposeBag()
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
        output.passwordValidation.drive(with: self) { owner, value in
            owner.joinSecondView.passwordView.descriptionLabel.textColor = value ? ColorStyle.subText : ColorStyle.caution
            owner.joinSecondView.passwordView.descriptionLabel.text = value ? nil : TextFieldType.password.description
        }.disposed(by: disposeBag)
        
        output.nextButtonValidation.drive(joinSecondView.nextButton.rx.isEnabled).disposed(by: disposeBag)
        
        output.nextButtonTap.bind(with: self) { owner, _ in
            let vc = JoinThirdViewController()
            vc.id = owner.id
            vc.password = owner.joinSecondView.passwordView.customTextField.text ?? ""
            owner.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: disposeBag)

    }
}
