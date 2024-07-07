//
//  JoinSuccessViewController.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 7/7/24.
//

import UIKit
import RxSwift
import RxCocoa

final class JoinSuccessViewController: BaseViewController {
    
    let viewModel = JoinSuccessViewModel()
    let joinSuccessView = JoinSuccessView()
    
    var id: String = ""
    var nickname: String = ""
    
    override func loadView() {
        self.view = joinSuccessView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func configureView() {
        joinSuccessView.idLabel.text = id
        joinSuccessView.nicknameLabel.text = nickname
    }
    
    override func bind() {
        let input = JoinSuccessViewModel.Input(
            startButtonTap: joinSuccessView.startButton.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.startButtonTap.drive(with: self) { owner, _ in
            TransitionManager.shared.setInitialViewController(LoginViewController(), navigation: true)
        }.disposed(by: disposeBag)
    }
}
