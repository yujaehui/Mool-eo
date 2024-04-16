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
    var password: String = ""
    
    override func loadView() {
        self.view = joinSecondView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func bind() {
        let id = Observable.just(id)
        let password = Observable.just(password)
        let name = joinSecondView.nicknameView.customTextField.rx.text.orEmpty.asObservable()
        let date = joinSecondView.datePicker.rx.date.asObservable()
        let joinButtonTap = joinSecondView.joinButton.rx.tap.asObservable()
        let input = JoinSecondViewModel.Input(id: id, password: password, name: name, date: date, joinButtonTap: joinButtonTap)
        
        let output = viewModel.transform(input: input)
        output.date.drive(joinSecondView.birthdayView.customTextField.rx.text).disposed(by: disposeBag)
    }
}
