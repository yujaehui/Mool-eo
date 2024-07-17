//
//  JoinSecondViewController.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/13/24.
//

import UIKit
import RxSwift
import RxCocoa

final class JoinSecondViewController: BaseViewController {
    
    deinit { print("‼️JoinSecondViewController Deinit‼️") }
    
    let viewModel = JoinSecondViewModel()
    let joinSecondView = JoinSecondView()
    
    private var id: String
    
    init(id: String) {
        self.id = id
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = joinSecondView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func bind() {
        let input = JoinSecondViewModel.Input(
            password: joinSecondView.passwordView.customTextField.rx.text.orEmpty.asObservable(),
            nextButtonTap: joinSecondView.nextButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.passwordValidation.drive(with: self) { owner, value in
            owner.joinSecondView.passwordView.descriptionLabel.textColor = value ? ColorStyle.available : ColorStyle.caution
            owner.joinSecondView.passwordView.descriptionLabel.text = value ? "사용 가능한 비밀번호입니다." : TextFieldType.password.description
        }.disposed(by: disposeBag)
        
        output.nextButtonValidation.drive(joinSecondView.nextButton.rx.isEnabled).disposed(by: disposeBag)
        
        output.nextButtonTap.drive(with: self) { owner, password in
            let vc = JoinThirdViewController(id: owner.id, password: password)
            owner.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: disposeBag)

    }
}
