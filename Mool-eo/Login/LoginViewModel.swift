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
        let id: Observable<String>
        let password: Observable<String>
        let loginButtonTap: Observable<Void>
        let joinButtonTap: Observable<Void>
    }
    
    struct Output {
        let keyboardWillShow: Observable<Notification>
        let keyboardWillHide: Observable<Notification>
        let loginValidation: Driver<Bool>
        let loginSuccessTrigger: Driver<Void>
        let joinButtonTap: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        let loginValidation = BehaviorSubject<Bool>(value: false)
        let loginSuccessTrigger = PublishSubject<Void>()
        
        let loginQuery = Observable.combineLatest(input.id, input.password).map { (id, password) in
            return LoginQuery(email: id, password: password)
        }
        
        loginQuery.bind(with: self) { owner, value in
            if value.email.count > 0 && value.password.count > 0 {
                loginValidation.onNext(true)
            } else {
                loginValidation.onNext(false)
            }
        }.disposed(by: disposeBag)
        
        // 로그인 네트워크 통신 진행
        input.loginButtonTap
            .withLatestFrom(loginQuery)
            .flatMap { loginQuery in
                return NetworkManager.login(query: loginQuery)
            }
            .debug("로그인")
            .subscribe(with: self) { owner, value in
                loginSuccessTrigger.onNext(())
            } onError: { owner, error in
                print("오류 발생")
            }.disposed(by: disposeBag)
        
        
        return Output(keyboardWillShow: input.keyboardWillShow,
                      keyboardWillHide: input.keyboardWillHide,
                      loginValidation: loginValidation.asDriver(onErrorJustReturn: false),
                      loginSuccessTrigger: loginSuccessTrigger.asDriver(onErrorJustReturn: ()),
                      joinButtonTap: input.joinButtonTap.asDriver(onErrorJustReturn: ()))
    }
}

