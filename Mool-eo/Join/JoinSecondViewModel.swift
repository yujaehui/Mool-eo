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
        let date: Observable<Date>
    }
    
    struct Output {
        let date: Driver<String>
    }
    
    func transform(input: Input) -> Output {

        let date = PublishRelay<String>()
        
        input.date
            .debug()
            .subscribe(with: self) { owner, value in
            date.accept(DateFormatterManager.shared.convertformatDateToString(date: value))
        }.disposed(by: disposeBag)
        
        return Output(date: date.asDriver(onErrorJustReturn: ""))
    }
}
