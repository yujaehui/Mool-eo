//
//  LoginViewModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/12/24.
//

import Foundation
import RxSwift
import RxCocoa

class LoginViewModel: ViewModelType {
    
    var disposeBag: DisposeBag = DisposeBag()
    
    struct Input {
        let keyboardWillShow: Observable<Notification>
        let keyboardWillHide: Observable<Notification>
    }
    
    struct Output {
        let keyboardWillShow: Observable<Notification>
        let keyboardWillHide: Observable<Notification>
    }
    
    func transform(input: Input) -> Output {
        return Output(keyboardWillShow: input.keyboardWillShow, keyboardWillHide: input.keyboardWillHide)
    }
}

