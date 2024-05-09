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
        let authenticationErr: Driver<Void>
        let badRequest: Driver<Void>
        let networkFail: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        let loginValidation = BehaviorSubject<Bool>(value: false)
        let loginSuccessTrigger = PublishSubject<Void>()
        let authenticationErr = PublishSubject<Void>()
        let badRequest = PublishSubject<Void>()
        let networkFail = PublishSubject<Void>()
        
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
                NetworkManager.shared.login(query: loginQuery)
            }
            .debug("로그인")
            .subscribe(with: self) { owner, value in
                switch value {
                case .success(let loginModel):
                    UserDefaultsManager.userId = loginModel.user_id
                    UserDefaultsManager.accessToken = loginModel.accessToken
                    UserDefaultsManager.refreshToken = loginModel.refreshToken
                    loginSuccessTrigger.onNext(())
                case .error(let error):
                    switch error {
                    case .authenticationErr: authenticationErr.onNext(())
                    case .badRequest: badRequest.onNext(())
                    case .networkFail: networkFail.onNext(())
                    default: print("⚠️OTHER ERROR : \(error)⚠️")
                    }
                }
            }
            .disposed(by: disposeBag)
        
        
        return Output(keyboardWillShow: input.keyboardWillShow,
                      keyboardWillHide: input.keyboardWillHide,
                      loginValidation: loginValidation.asDriver(onErrorJustReturn: false),
                      loginSuccessTrigger: loginSuccessTrigger.asDriver(onErrorJustReturn: ()),
                      joinButtonTap: input.joinButtonTap.asDriver(onErrorJustReturn: ()),
                      authenticationErr: authenticationErr.asDriver(onErrorJustReturn: ()),
                      badRequest: badRequest.asDriver(onErrorJustReturn: ()),
                      networkFail: networkFail.asDriver(onErrorJustReturn: ()))
    }
}

