//
//  ShoppingViewModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/19/24.
//

import Foundation
import RxSwift
import RxCocoa

class ShoppingViewModel: ViewModelType {
    var disposeBag: DisposeBag = DisposeBag()
    
    struct Input {
        let reload: BehaviorSubject<Void>
    }
    
    struct Output {
        let result: PublishSubject<PaymentModel>
        let networkFail: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        let result = PublishSubject<PaymentModel>()
        let networkFail = PublishSubject<Void>()
        
        input.reload
            .map {
                return UserDefaultsManager.userId!
            }
            .flatMap { userId in
                NetworkManager.shared.paymentCheck().asObservable()
            }
            .debug("프로필 및 유저 포스트 조회")
            .subscribe(with: self) { owner, value in
                switch value {
                case .success(let paymentModel):
                    result.onNext(paymentModel)
                case .error(let paymentError):
                    switch paymentError {
                    case .networkFail: networkFail.onNext(())
                    default: print("⚠️OTHER ERROR : \(paymentError)⚠️")
                    }
                }
            }.disposed(by: disposeBag)

        
        return Output(result: result,
                      networkFail: networkFail.asDriver(onErrorJustReturn: ()))
    }
}
