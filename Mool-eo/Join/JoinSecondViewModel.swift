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
        let id: Observable<String>
        let password: Observable<String>
        let name: Observable<String>
        let date: Observable<Date>
        let joinButtonTap: Observable<Void>
    }
    
    struct Output {
        let date: Driver<String>
    }
    
    func transform(input: Input) -> Output {
        let date = BehaviorSubject<String>(value: DateFormatterManager.shared.convertformatDateToString(date: Date()))
        let joinButtonValidation = BehaviorSubject<Bool>(value: false)
        
        input.date
            .debug("date")
            .subscribe(with: self) { owner, value in
            date.onNext(DateFormatterManager.shared.convertformatDateToString(date: value))
        }.disposed(by: disposeBag)
        
        
        let joinObservable = Observable.combineLatest(input.id, input.password, input.name, date.asObservable())
            .map { (id, password, name, birthday) in
                return JoinQuery(email: id, password: password, nick: name, birthDay: birthday)
            }
        
        joinObservable
            .debug("joinObservable")
            .bind(with: self) { owner, value in
                if value.nick.count > 0 && value.birthDay.count > 0 {
                    joinButtonValidation.onNext(true)
                } else {
                    joinButtonValidation.onNext(false)
                }
            }.disposed(by: disposeBag)
        
        input.joinButtonTap
            .withLatestFrom(joinObservable)
            .flatMap { query in
                NetworkManager.join(query: query)
            }
            .debug("joinButtonTap")
            .subscribe(with: self) { owner, value in
                print("회원가입 성공")
            }.disposed(by: disposeBag)
        
        return Output(date: date.asDriver(onErrorJustReturn: ""))
    }
}
