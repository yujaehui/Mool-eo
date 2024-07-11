//
//  SettingViewModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/12/24.
//

import Foundation
import RxSwift
import RxCocoa

final class SettingViewModel: ViewModelType {
    
    var disposeBag: DisposeBag = DisposeBag()
    
    struct Input {
        let reload: BehaviorSubject<Void>
        let modelSelected: Observable<SettingSectionItem>
        let itemSelected: Observable<IndexPath>
        let withdrawButtonTap: PublishSubject<Void>
    }
    
    struct Output {
        let profile: PublishSubject<ProfileModel>
        let withdrawCheck: PublishSubject<Void>
        let withdrawSuccessTrigger: PublishSubject<Void>
        let networkFail: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        let profile = PublishSubject<ProfileModel>()
        let withdrawCheck = PublishSubject<Void>()
        let withdrawSuccessTrigger = PublishSubject<Void>()
        let networkFail = PublishSubject<Void>()
        
        input.reload
            .flatMap { NetworkManager.shared.profileCheck() }
            .subscribe(with: self) { owner, value in
                switch value {
                case .success(let success): profile.onNext(success)
                case .error(let error): owner.handleNetworkError(error: error, networkFail: networkFail)
                }
            }
            .disposed(by: disposeBag)
        
        Observable.zip(input.modelSelected, input.itemSelected)
            .map { $0.0 }
            .bind(with: self) { owner, value in
                switch value {
                case .info(_): break
                case .management(_): withdrawCheck.onNext(())
                }
            }
            .disposed(by: disposeBag)
        
        input.withdrawButtonTap
            .flatMap { NetworkManager.shared.withdraw() }
            .subscribe(with: self) { owner, value in
                switch value {
                case .success(_): withdrawSuccessTrigger.onNext(())
                case .error(let error): owner.handleNetworkError(error: error, networkFail: networkFail)
                }
            }
            .disposed(by: disposeBag)
        
        return Output(profile: profile,
                      withdrawCheck: withdrawCheck,
                      withdrawSuccessTrigger: withdrawSuccessTrigger,
                      networkFail: networkFail.asDriver(onErrorJustReturn: ()))
    }
    
    private func handleNetworkError(error: NetworkError, networkFail: PublishSubject<Void>) {
        switch error {
        case .networkFail: networkFail.onNext(())
        default: print("⚠️OTHER ERROR : \(error)⚠️")
        }
    }
}
