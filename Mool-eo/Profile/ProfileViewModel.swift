//
//  ProfileViewModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/17/24.
//

import Foundation
import RxSwift
import RxCocoa

class ProfileViewModel: ViewModelType {
    var disposeBag: DisposeBag = DisposeBag()
    
    struct Input {
        let viewDidLoadTrigger: Observable<Void>
    }
    
    struct Output {
        let profile: PublishSubject<ProfileModel>
    }
    
    func transform(input: Input) -> Output {
        let profile = PublishSubject<ProfileModel>()
        
        input.viewDidLoadTrigger
            .flatMap { _ in
                NetworkManager.profileCheck()
            }
            .debug("프로필 조회")
            .subscribe(with: self) { owner, value in
                profile.onNext(value)
            } onError: { owner, error in
                print("오류 발생")
            }.disposed(by: disposeBag)
        
        return Output(profile: profile)
    }
}
