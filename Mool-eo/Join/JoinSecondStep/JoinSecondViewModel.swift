//
//  JoinSecondViewModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/13/24.
//

import Foundation
import RxSwift
import RxCocoa

class JoinSecondViewModel: ViewModelType {
    var disposeBag: DisposeBag = DisposeBag()
    
    struct Input {
        let password: Observable<String>
        let nextButtonTap: Observable<Void>
    }
    
    struct Output {
        let passwordValidation: Driver<Bool>
        let nextButtonValidation: Driver<Bool>
        let nextButtonTap: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        let passwordValidation = BehaviorSubject<Bool>(value: false)
        let nextButtonValidation = BehaviorSubject<Bool>(value: false)
        
        input.password
            .map { value in
                let passwordRegex = "^(?=.*[a-z])(?=.*\\d)[a-z\\d]{4,12}$"
                let passwordPredicate = NSPredicate(format: "SELF MATCHES %@", passwordRegex)
                return passwordPredicate.evaluate(with: value)
            }
            .debug("비밀번호")
            .bind(with: self) { owner, value in
                passwordValidation.onNext(value)
            }.disposed(by: disposeBag)
        
        passwordValidation
            .bind(with: self) { owner, value in
                nextButtonValidation.onNext(value)
            }.disposed(by: disposeBag)
        
        return Output(passwordValidation: passwordValidation.asDriver(onErrorJustReturn: false),
                      nextButtonValidation: nextButtonValidation.asDriver(onErrorJustReturn: false),
                      nextButtonTap: input.nextButtonTap.asDriver(onErrorJustReturn: ()))
    }
}
