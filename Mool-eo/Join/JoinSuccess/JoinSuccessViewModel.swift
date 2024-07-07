//
//  JoinSuccessViewModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 7/7/24.
//

import Foundation
import RxSwift
import RxCocoa

final class JoinSuccessViewModel: ViewModelType {
    var disposeBag: DisposeBag = DisposeBag()
    
    struct Input {
        let startButtonTap: Observable<Void>
    }
    
    struct Output {
        let startButtonTap: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        return Output(startButtonTap: input.startButtonTap.asDriver(onErrorJustReturn: ()))
    }
}
