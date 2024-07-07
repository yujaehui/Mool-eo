//
//  JoinSecondViewModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/13/24.
//

import Foundation
import RxSwift
import RxCocoa

final class JoinSecondViewModel: ViewModelType {
    var disposeBag: DisposeBag = DisposeBag()
    
    struct Input {
        let password: Observable<String>
        let nextButtonTap: Observable<Void>
    }
    
    struct Output {
        let passwordValidation: Driver<Bool>
        let nextButtonValidation: Driver<Bool>
        let nextButtonTap: Driver<String>
    }
    
    func transform(input: Input) -> Output {
        let passwordValidation = BehaviorSubject<Bool>(value: false)
        let nextButtonValidation = BehaviorSubject<Bool>(value: false)
        let nextButtonTap = PublishSubject<String>()
        
        input.password
            .map { value in
                let passwordRegex = "^(?=.*[a-z])(?=.*\\d)[a-z\\d]{4,12}$"
                let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
                return passwordPredicate.evaluate(with: value)
            }
            .bind(with: self) { owner, value in
                passwordValidation.onNext(value)
            }.disposed(by: disposeBag)
        
        passwordValidation
            .bind(with: self) { owner, value in
                nextButtonValidation.onNext(value)
            }.disposed(by: disposeBag)
        
        input.nextButtonTap
            .withLatestFrom(input.password)
            .bind(with: self) { owner, password in
                nextButtonTap.onNext(password)
            }.disposed(by: disposeBag)
        
        return Output(passwordValidation: passwordValidation.asDriver(onErrorJustReturn: false),
                      nextButtonValidation: nextButtonValidation.asDriver(onErrorJustReturn: false),
                      nextButtonTap: nextButtonTap.asDriver(onErrorJustReturn: ""))
    }
}
