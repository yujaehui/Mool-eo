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
        let joinButtonTap: Observable<Void>
        let id: Observable<String>
        let password: Observable<String>
        let loginButtonTap: Observable<Void>
    }
    
    struct Output {
        let keyboardWillShow: Observable<Notification>
        let keyboardWillHide: Observable<Notification>
        let joinButtonTap: Observable<Void>
        let loginValidation: Driver<Bool>
        let loginSuccessTrigger: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        let loginValidation = BehaviorSubject<Bool>(value: false)
        let loginSuccessTrigger = PublishSubject<Void>()
        
        let loginObservable = Observable.combineLatest(input.id, input.password).map { (id, password) in
            return LoginQuery(email: id, password: password)
        }
        
        loginObservable.bind(with: self) { owner, value in
            if value.email.count > 0 && value.password.count > 0 {
                loginValidation.onNext(true)
            } else {
                loginValidation.onNext(false)
            }
        }.disposed(by: disposeBag)
        
        input.loginButtonTap
            .withLatestFrom(loginObservable)
            .flatMap { loginQuery in
                return NetworkManager.login(query: loginQuery)
            }
            .debug("login")
            .subscribe(with: self) { owner, value in
                loginSuccessTrigger.onNext(())
            } onError: { owner, error in
                print("오류 발생")
            }.disposed(by: disposeBag)
        
        
        return Output(keyboardWillShow: input.keyboardWillShow,
                      keyboardWillHide: input.keyboardWillHide,
                      joinButtonTap: input.joinButtonTap,
                      loginValidation: loginValidation.asDriver(onErrorJustReturn: false),
                      loginSuccessTrigger: loginSuccessTrigger.asDriver(onErrorJustReturn: ()))
    }
}

