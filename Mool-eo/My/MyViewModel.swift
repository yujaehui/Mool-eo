//
//  MyViewModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/29/24.
//

import Foundation
import RxSwift
import RxCocoa

class MyViewModel: ViewModelType {
    var disposeBag: DisposeBag = DisposeBag()
    
    struct Input {
        let reload: BehaviorSubject<Void>
        let profileEditButtonTap: Observable<Void>
    }
    
    struct Output {
        let profile: PublishSubject<ProfileModel>
        let profileEditButtonTap: PublishSubject<ProfileModel>
    }
    
    func transform(input: Input) -> Output {
        let profile = PublishSubject<ProfileModel>()
        let profileEditButtonTap = PublishSubject<ProfileModel>()
        
        input.reload
            .flatMap { _ in
                NetworkManager.shared.profileCheck()
            }
            .debug("프로필 조회")
            .subscribe(with: self) { owner, value in
                switch value {
                case .success(let profileModel):
                    profile.onNext(profileModel)
                case .error(let error):
                    print(error)
                }
            }.disposed(by: disposeBag)
        
        input.profileEditButtonTap
            .flatMap { _ in
                NetworkManager.shared.profileCheck()
            }
            .debug("프로필 조회")
            .subscribe(with: self) { owner, value in
                switch value {
                case .success(let profileModel):
                    profileEditButtonTap.onNext(profileModel)
                case .error(let error):
                    print(error)
                }
            }.disposed(by: disposeBag)
        
        return Output(profile: profile, profileEditButtonTap: profileEditButtonTap)
    }
}
