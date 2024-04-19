//
//  JoinViewModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/13/24.
//

import Foundation
import RxSwift
import RxCocoa

class JoinViewModel: ViewModelType {
    var disposeBag: DisposeBag = DisposeBag()
    
    struct Input {
        let id: Observable<String>
        let idCheckButtonTap: Observable<Void>
        let nextButtonTap: Observable<Void>
    }
    
    struct Output {
        let idValidation: Driver<Bool>
        let idCheckValidation: Driver<Bool?>
        let idCheckMessage: Driver<String>
        let nextButtonValidation: Driver<Bool>
        let nextButtonTap: Observable<Void>
    }
    
    func transform(input: Input) -> Output {
        let idValidation = BehaviorSubject<Bool>(value: false)
        let idCheckValidation = BehaviorSubject<Bool?>(value: false)
        let idCheckMessage = PublishSubject<String>()
        let nextButtonValidation = BehaviorSubject<Bool>(value: false)
        
        input.id
            .map { id in
                let idRegex = "^(?!\\s)(?=.*[a-z])[a-z0-9]{4,12}$"
                let idPredicate = NSPredicate(format: "SELF MATCHES %@", idRegex)
                return idPredicate.evaluate(with: id)
            }
            .debug("id")
            .bind(with: self) { owner, value in
                idValidation.onNext(value)
                idCheckValidation.onNext(nil) // 값이 변경되면 중복 확인을 진행하지 않은 상태로 돌려놔야 하기 때문에
            }.disposed(by: disposeBag)
        
        input.idCheckButtonTap
            .withLatestFrom(input.id)
            .map { id in
                return EmailQuery(email: id)
            }
            .flatMap { query in
                NetworkManager.emailCheck(query: query)
            }
            .debug("idCheck")
            .bind(with: self) { owner, value in
                if value.message == "사용 가능한 이메일입니다." {
                    idCheckMessage.onNext("사용 가능한 아이디입니다.")
                    idCheckValidation.onNext(true)
                } else {
                    idCheckMessage.onNext("사용할 수 없는 아이디입니다.")
                    idCheckValidation.onNext(false)
                }
            }.disposed(by: disposeBag)
        
        idCheckValidation
            .map { value in
                guard let value = value else { return false }
                return value
            }
            .bind(with: self) { owner, value in
                nextButtonValidation.onNext(value)
            }.disposed(by: disposeBag)
        
        
        return Output(idValidation: idValidation.asDriver(onErrorJustReturn: false),
                      idCheckValidation: idCheckValidation.asDriver(onErrorJustReturn: nil),
                      idCheckMessage: idCheckMessage.asDriver(onErrorJustReturn: ""),
                      nextButtonValidation: nextButtonValidation.asDriver(onErrorJustReturn: false),
                      nextButtonTap: input.nextButtonTap)
    }
}
