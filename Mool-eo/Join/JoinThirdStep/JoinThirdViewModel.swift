//
//  JoinThirdViewModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/19/24.
//

import Foundation
import RxSwift
import RxCocoa

final class JoinThirdViewModel: ViewModelType {
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
        let joinSuccessTrigger: Driver<JoinModel>
        let networkFail: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        let nicknameValidation = BehaviorSubject<Bool>(value: false)
        let joinButtonValidation = BehaviorSubject<Bool>(value: false)
        let joinSuccessTrigger = PublishSubject<JoinModel>()
        let networkFail = PublishSubject<Void>()

        input.nickname
            .map { value in
                let idRegex = "^[^\\s]{2,10}$"
                let idPredicate = NSPredicate(format: "SELF MATCHES %@", idRegex)
                return idPredicate.evaluate(with: value)
            }
            .bind(with: self) { owner, value in
                nicknameValidation.onNext(value)
            }.disposed(by: disposeBag)
        
        nicknameValidation
            .bind(with: self) { owner, value in
                joinButtonValidation.onNext(value)
            }.disposed(by: disposeBag)
        
        let joinQuery = Observable.combineLatest(input.id, input.password, input.nickname)
            .map { (id, password, nickname) in
                return JoinQuery(email: id, password: password, nick: nickname)
            }
        
        input.joinButtonTap
            .withLatestFrom(joinQuery)
            .flatMap { query in
                NetworkManager.shared.join(query: query)
            }
            .subscribe(with: self) { owner, value in
                switch value {
                case .success(let joinModel): joinSuccessTrigger.onNext(joinModel)
                case .error(let error):
                    switch error {
                    case .networkFail: networkFail.onNext(())
                    default: print("⚠️OTHER ERROR : \(error)⚠️")
                    }
                }
            }.disposed(by: disposeBag)
        
        return Output(nicknameValidation: nicknameValidation.asDriver(onErrorJustReturn: false),
                      joinButtonValidation: joinButtonValidation.asDriver(onErrorJustReturn: false),
                      joinSuccessTrigger: joinSuccessTrigger.asDriver(onErrorJustReturn: JoinModel(user_id: "", email: "", nick: "")),
                      networkFail: networkFail.asDriver(onErrorJustReturn: ()))
    }
}
