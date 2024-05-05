//
//  JoinViewController.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/13/24.
//

import UIKit
import RxSwift

// 회원가입 첫번째 로직 : 아이디 입력 & 중복 확인
class JoinViewController: BaseViewController {
    
    deinit {
        print("‼️JoinViewController Deinit‼️")
    }
    
    let viewModel = JoinViewModel()
    let joinView = JoinView()
    
    override func loadView() {
        self.view = joinView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true) // 화면 터치시 키보드 내려가도록
    }
    
    override func setNav() {
        navigationItem.backButtonTitle = ""
        navigationController?.navigationBar.tintColor = ColorStyle.point
    }
    
    override func bind() {
        let id = joinView.idView.customTextField.rx.text.orEmpty.asObservable()
        let idCheckButtonTap = joinView.idCheckButton.rx.tap.asObservable()
        let nextButtonTap = joinView.nextButton.rx.tap.asObservable()
        let input = JoinViewModel.Input(id: id, idCheckButtonTap: idCheckButtonTap, nextButtonTap: nextButtonTap)
        
        let output = viewModel.transform(input: input)
        
        // 아이디 기본 조건
        output.idValidation.drive(with: self) { owner, value in
            owner.joinView.idCheckButton.isEnabled = value
            owner.joinView.idView.descriptionLabel.textColor = value ? ColorStyle.subText : ColorStyle.caution
            owner.joinView.idView.descriptionLabel.text = value ? "중복 확인을 진행해주세요." : TextFieldType.id.description
        }.disposed(by: disposeBag)
        
        // 아이디 중복 확인 조건
        output.idCheckSuccessValidation.drive(with: self) { owner, value in
            guard let value = value else { return } // nil일 경우 종료
            owner.joinView.idView.descriptionLabel.textColor = value ? ColorStyle.available : ColorStyle.caution
            owner.joinView.idView.descriptionLabel.text = value ? "사용 가능한 아이디입니다." : "사용할 수 없는 아이디입니다."
        }.disposed(by: disposeBag)
        
        output.nextButtonValidation.drive(joinView.nextButton.rx.isEnabled).disposed(by: disposeBag)
        
        // 다음 버튼을 클릭했을 경우, 회원가입 두번째 로직으로 이동
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
