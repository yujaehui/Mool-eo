//
//  JoinThirdViewModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/19/24.
//

import Foundation
import RxSwift
import RxCocoa

class JoinThirdViewModel: ViewModelType {
    var disposeBag: DisposeBag = DisposeBag()
    
    struct Input {
        let id: Observable<String>
        let password: Observable<String>
        let nickname: Observable<String>
        let joinButtonTap: Observable<Void>
    }
    
    struct Output {
        let nicknameValidation: Driver<Bool>
        let joinButtonValidation: Driver<Bool>
        let joinSuccessTrigger: PublishSubject<Void>
    }
    
    func transform(input: Input) -> Output {
        let nicknameValidation = BehaviorSubject<Bool>(value: false)
        let joinButtonValidation = BehaviorSubject<Bool>(value: false)
        let joinSuccessTrigger = PublishSubject<Void>()
        
        input.nickname
            .map { value in
                let idRegex = "^[^\\s]{2,10}$"
                let idPredicate = NSPredicate(format: "SELF MATCHES %@", idRegex)
                return idPredicate.evaluate(with: value)
            }
            .debug("nickname")
            .bind(with: self) { owner, value in
                nicknameValidation.onNext(value)
            }.disposed(by: disposeBag)
        
        nicknameValidation
            .bind(with: self) { owner, value in
                joinButtonValidation.onNext(value)
            }.disposed(by: disposeBag)
        
        let joinObservable = Observable.combineLatest(input.id, input.password, input.nickname)
            .map { (id, password, nickname) in
                return JoinQuery(email: id, password: password, nick: nickname)
            }
        
        input.joinButtonTap
            .withLatestFrom(joinObservable)
            .flatMap { query in
                NetworkManager.join(query: query)
            }
            .debug("join")
            .subscribe(with: self) { owner, value in
                joinSuccessTrigger.onNext(())
            } onError: { owner, error in
                print("오류 발생")
            }.disposed(by: disposeBag)
        
        return Output(nicknameValidation: nicknameValidation.asDriver(onErrorJustReturn: false),
                      joinButtonValidation: joinButtonValidation.asDriver(onErrorJustReturn: false),
                      joinSuccessTrigger: joinSuccessTrigger)
    }
}
