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
    
    override func loadView() {
        self.view = joinSecondView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func bind() {
        let date = joinSecondView.datePicker.rx.date.asObservable()
        let input = JoinSecondViewModel.Input(date: date)
        
        let output = viewModel.transform(input: input)
        output.date.drive(joinSecondView.birthdayView.customTextField.rx.text).disposed(by: disposeBag)
    }
}
