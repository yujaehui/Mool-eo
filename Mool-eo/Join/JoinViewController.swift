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
        let idCheckButtonTap = joinView.idCheckButton.rx.tap.asObservable()
        let nextButtonTap = joinView.nextButton.rx.tap.asObservable()
        let input = JoinViewModel.Input(id: id, idCheckButtonTap: idCheckButtonTap, nextButtonTap: nextButtonTap)
        
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
        
        output.nextButtonValidation.drive(joinView.nextButton.rx.isEnabled).disposed(by: disposeBag)
        
        output.nextButtonTap.bind(with: self) { owner, _ in
            let vc = JoinSecondViewController()
            vc.id = owner.joinView.idView.customTextField.text ?? ""
            owner.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: disposeBag)
    }
}
