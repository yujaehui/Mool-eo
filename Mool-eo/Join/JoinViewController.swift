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
        let idEditingChanged = joinView.idView.customTextField.rx.controlEvent(.editingChanged).asObservable()
        let idCheckButtonTap = joinView.idCheckButton.rx.tap.asObservable()
        let password = joinView.passwordView.customTextField.rx.text.orEmpty.asObservable()
        let passwordEditingChanged = joinView.passwordView.customTextField.rx.controlEvent(.editingChanged).asObservable()
        let nextButtonTap = joinView.nextButton.rx.tap.asObservable()
        let input = JoinViewModel.Input(id: id, idEditingChanged: idEditingChanged, 
                                        idCheckButtonTap: idCheckButtonTap,
                                        password: password, passwordEditingChanged: passwordEditingChanged,
                                        nextButtonTap: nextButtonTap)
        
        let output = viewModel.transform(input: input)
        
        output.idValidation.drive(with: self) { owner, value in
            owner.joinView.idCheckButton.isEnabled = value
            owner.joinView.idView.descriptionLabel.textColor = value ? ColorStyle.subText : ColorStyle.caution
            owner.joinView.idView.descriptionLabel.text = value ? nil : TextFieldType.id.description
        }.disposed(by: disposeBag)
        
        output.idCheckValidation.drive(with: self) { owner, value in
            guard let value = value else { return }
            owner.joinView.idView.descriptionLabel.textColor = value ? ColorStyle.available : ColorStyle.caution
        }.disposed(by: disposeBag)
        
        output.idCheckMessage.drive(with: self) { owner, value in
            owner.joinView.idView.descriptionLabel.text = value
        }.disposed(by: disposeBag)
        
        output.passwordValidation.drive(with: self) { owner, value in
            owner.joinView.passwordView.descriptionLabel.text = value ? nil : TextFieldType.id.description
            owner.joinView.passwordView.descriptionLabel.textColor = value ? nil : ColorStyle.caution
        }.disposed(by: disposeBag)
        
        output.nextButtonValidation.drive(with: self) { owner, value in
            owner.joinView.nextButton.isEnabled = value
        }.disposed(by: disposeBag)
        
        output.nextButtonTap.bind(with: self) { owner, _ in
            let vc = JoinSecondViewController()
            vc.id = owner.joinView.idView.customTextField.text ?? ""
            vc.password = owner.joinView.passwordView.customTextField.text ?? ""
            owner.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: disposeBag)
    }
}
