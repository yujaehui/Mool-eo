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
        let viewDidLoad: Observable<Void>
    }
    
    struct Output {
        let result: PublishSubject<(ProfileModel, PostListModel)>
        
    }
    
    func transform(input: Input) -> Output {
        let result = PublishSubject<(ProfileModel, PostListModel)>()
        
        input.viewDidLoad
            .flatMap { _ in
                Observable.zip(NetworkManager.profileCheck().asObservable(), NetworkManager.postCheckUser().asObservable())
            }
            .debug("프로필 및 유저 포스트 조회")
            .subscribe(with: self) { owner, value in
                result.onNext(value)
            } onError: { owner, error in
                print("오류 발생")
            }
            .disposed(by: disposeBag)        
        
        return Output(result: result)
    }
}
