//
//  ProfilePaymentListViewModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 7/2/24.
//

import Foundation
import RxSwift
import RxCocoa

final class ProfilePaymentListViewModel: ViewModelType {
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

