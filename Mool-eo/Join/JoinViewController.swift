//
//  JoinViewController.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/13/24.
//

import UIKit
import RxSwift
import Toast

class JoinViewController: BaseViewController {
    
    let disposeBag = DisposeBag()
    let viewModel = JoinViewModel()
    let joinView = JoinView()
    
    override func loadView() {
        self.view = joinView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func bind() {
        let id = joinView.idView.customTextField.rx.text.orEmpty.asObservable()
        let password = joinView.passwordView.customTextField.rx.text.orEmpty.asObservable()
        let idCheckButtonTap = joinView.idCheckButton.rx.tap.asObservable()
        let nextButtonTap = joinView.nextButton.rx.tap.asObservable()
        let input = JoinViewModel.Input(id: id, password: password, idCheckButtonTap: idCheckButtonTap, nextButtonTap: nextButtonTap)
        
        let output = viewModel.transform(input: input)
        
        output.idValidation.drive(with: self) { owner, value in
            owner.joinView.idCheckButton.isEnabled = value
            owner.joinView.idView.descriptionLabel.textColor = value ? ColorStyle.subText : ColorStyle.caution
            owner.joinView.idView.descriptionLabel.text = TextFieldType.id.description
        }.disposed(by: disposeBag)
        
        output.idCheckValidation.drive(with: self) { owner, value in
            guard let value = value else { return }
            owner.joinView.idView.descriptionLabel.textColor = value ? ColorStyle.subText : ColorStyle.caution
        }.disposed(by: disposeBag)
        
        output.idCheckMessage.drive(with: self) { owner, value in
            owner.joinView.idView.descriptionLabel.text = value.message
        }.disposed(by: disposeBag)
        
        output.passwordValidation.drive(with: self) { owner, value in
            owner.joinView.passwordView.descriptionLabel.textColor = value ? ColorStyle.subText : ColorStyle.caution
        }.disposed(by: disposeBag)
        
        output.nextButtonValidation.drive(with: self) { owner, value in
            owner.joinView.nextButton.isEnabled = value
        }.disposed(by: disposeBag)
        
        output.nextButtonTap.bind(with: self) { owner, _ in
            owner.navigationController?.pushViewController(JoinSecondViewController(), animated: true)
        }.disposed(by: disposeBag)
    }
}
