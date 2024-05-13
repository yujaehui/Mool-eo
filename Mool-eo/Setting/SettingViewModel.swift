//
//  SettingViewModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/12/24.
//

import Foundation
import RxSwift
import RxCocoa

class SettingViewModel: ViewModelType {
    
    var disposeBag: DisposeBag = DisposeBag()
    
    struct Input {
        let reload: BehaviorSubject<Void>
        let modelSelected: Observable<SettingSectionItem>
        let itemSelected: Observable<IndexPath>
    }
    
    struct Output {
        let profile: PublishSubject<ProfileModel>
        let withdrawSuccessTrigger: PublishSubject<Void>
    }
    
    func transform(input: Input) -> Output {
        let profile = PublishSubject<ProfileModel>()
        let withdraw = PublishSubject<Void>()
        let withdrawSuccessTrigger = PublishSubject<Void>()
        
        input.reload
            .flatMap { _ in
                NetworkManager.shared.profileCheck()
            }
            .subscribe(with: self) { owner, value in
                switch value {
                case .success(let success): profile.onNext(success)
                case .error(let error): print(error)
                }
            }.disposed(by: disposeBag)
        
        Observable.zip(input.modelSelected, input.itemSelected)
            .bind(with: self) { owner, value in
                switch value.0 {
                case .info(_): break
                case .management(let management): withdraw.onNext(())
                }
            }.disposed(by: disposeBag)
        
        withdraw
            .flatMap { _ in
                NetworkManager.shared.withdraw()
            }
            .subscribe(with: self) { owner, value in
                withdrawSuccessTrigger.onNext(())
            }.disposed(by: disposeBag)
        
        return Output(profile: profile, withdrawSuccessTrigger: withdrawSuccessTrigger)
    }
}
