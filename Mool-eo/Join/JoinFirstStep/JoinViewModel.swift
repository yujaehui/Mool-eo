//
//  JoinViewModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/13/24.
//

import Foundation
import RxSwift
import RxCocoa

final class JoinViewModel: ViewModelType {
    var disposeBag: DisposeBag = DisposeBag()
    
    struct Input {
        let id: Observable<String>
        let idCheckButtonTap: Observable<Void>
        let nextButtonTap: Observable<Void>
    }
    
    struct Output {
        let idValidation: Driver<Bool>
        let idCheckSuccessValidation: Driver<Bool?>
        let nextButtonValidation: Driver<Bool>
        let nextButtonTap: Driver<String>
        let networkFail: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        let idValidation = BehaviorSubject<Bool>(value: false)
        let idCheckSuccessValidation = BehaviorSubject<Bool?>(value: false) // true일 경우 사용 가능, false일 경우 중복, 사용 불가능, nil일 경우 중복 확인 안 함
        let nextButtonValidation = BehaviorSubject<Bool>(value: false)
        let nextButtonTap = PublishSubject<String>()
        let networkFail = PublishSubject<Void>()
        
        input.id
            .map { id in
                let idRegex = "^(?=.*[a-z])(?=.*\\d)[a-z\\d]{4,12}$"
                let idPredicate = NSPredicate(format: "SELF MATCHES %@", idRegex)
                return idPredicate.evaluate(with: id)
            }
            .bind(with: self) { owner, value in
                idValidation.onNext(value)
                idCheckSuccessValidation.onNext(nil) // 값이 변경되면 중복 확인을 진행하지 않은 상태로
            }.disposed(by: disposeBag)
        
        input.idCheckButtonTap
            .withLatestFrom(input.id)
            .map { id in
                return EmailQuery(email: id)
            }
            .flatMap { query in
                NetworkManager.shared.emailCheck(query: query)
            }
            .subscribe(with: self) { owner, value in
                switch value {
                case .success(_): idCheckSuccessValidation.onNext(true)
                case .error(let error):
                    switch error {
                    case .conflict: idCheckSuccessValidation.onNext(false)
                    case .networkFail: networkFail.onNext(())
                    default: print("⚠️OTHER ERROR : \(error)⚠️")
                    }
                }
            }.disposed(by: disposeBag)
        
        idCheckSuccessValidation
            .map { value in
                guard let value = value else { return false }
                return value
            }
            .bind(with: self) { owner, value in
                nextButtonValidation.onNext(value)
            }.disposed(by: disposeBag)
        
        input.nextButtonTap
            .withLatestFrom(input.id)
            .bind(with: self) { owner, id in
                nextButtonTap.onNext(id)
            }.disposed(by: disposeBag)
        
        
        return Output(idValidation: idValidation.asDriver(onErrorJustReturn: false),
                      idCheckSuccessValidation: idCheckSuccessValidation.asDriver(onErrorJustReturn: nil),
                      nextButtonValidation: nextButtonValidation.asDriver(onErrorJustReturn: false),
                      nextButtonTap: nextButtonTap.asDriver(onErrorJustReturn: ""),
                      networkFail: networkFail.asDriver(onErrorJustReturn: ()))
    }
}
