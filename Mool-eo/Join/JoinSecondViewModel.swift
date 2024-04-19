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
        let nextButtonTap: Observable<Void>
    }
    
    func transform(input: Input) -> Output {
        let passwordValidation = BehaviorSubject<Bool>(value: false)
        let nextButtonValidation = BehaviorSubject<Bool>(value: false)
        
        input.password
            .map { value in
                let idRegex = "^(?!\\s)(?=.*[a-z])[a-z0-9]{4,12}$"
                let idPredicate = NSPredicate(format: "SELF MATCHES %@", idRegex)
                return idPredicate.evaluate(with: value)
            }
            .debug("password")
            .bind(with: self) { owner, value in
                passwordValidation.onNext(value)
            }.disposed(by: disposeBag)
        
        passwordValidation
            .bind(with: self) { owner, value in
                nextButtonValidation.onNext(value)
            }.disposed(by: disposeBag)
        
        return Output(passwordValidation: passwordValidation.asDriver(onErrorJustReturn: false),
                      nextButtonValidation: nextButtonValidation.asDriver(onErrorJustReturn: false),
                      nextButtonTap: input.nextButtonTap)
    }
}
