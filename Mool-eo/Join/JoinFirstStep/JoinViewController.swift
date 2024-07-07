//
//  JoinViewController.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/13/24.
//

import UIKit
import RxSwift

final class JoinViewController: BaseViewController {
    
    deinit { print("‼️JoinViewController Deinit‼️") }
    
    let viewModel = JoinViewModel()
    let joinView = JoinView()
    
    override func loadView() {
        self.view = joinView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func bind() {
        let input = JoinViewModel.Input(
            id: joinView.idView.customTextField.rx.text.orEmpty.asObservable(),
            idCheckButtonTap: joinView.idCheckButton.rx.tap.asObservable(),
            nextButtonTap: joinView.nextButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.idValidation.drive(with: self) { owner, value in
            owner.joinView.idCheckButton.isEnabled = value
            owner.joinView.idView.descriptionLabel.textColor = value ? ColorStyle.subText : ColorStyle.caution
            owner.joinView.idView.descriptionLabel.text = value ? "중복 확인을 진행해주세요." : TextFieldType.id.description
        }.disposed(by: disposeBag)
        
        output.idCheckSuccessValidation.drive(with: self) { owner, value in
            guard let value = value else { return } // nil일 경우 종료
            owner.joinView.idView.descriptionLabel.textColor = value ? ColorStyle.available : ColorStyle.caution
            owner.joinView.idView.descriptionLabel.text = value ? "사용 가능한 아이디입니다." : "사용할 수 없는 아이디입니다."
        }.disposed(by: disposeBag)
        
        output.nextButtonValidation.drive(joinView.nextButton.rx.isEnabled).disposed(by: disposeBag)
        
        output.nextButtonTap.drive(with: self) { owner, _ in
            let vc = JoinSecondViewController()
            vc.id = owner.joinView.idView.customTextField.text ?? ""
            owner.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: disposeBag)
        
        output.networkFail.drive(with: self) { owner, _ in
            ToastManager.shared.showErrorToast(title: .networkFail, in: owner.joinView)
        }.disposed(by: disposeBag)
    }
}
