//
//  OtherUserProfileViewModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/2/24.
//

import Foundation
import RxSwift
import RxCocoa

class OtherUserProfileViewModel: ViewModelType {
    var disposeBag: DisposeBag = DisposeBag()
    
    struct Input {
        let reload: BehaviorSubject<Void>
        let userId: String
        let followStatus: PublishSubject<Bool>
    }
    
    struct Output {
        let result: PublishSubject<(OtherUserProfileModel, PostListModel)>
        let followOrUnfollowSuccessTrigger: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        let result = PublishSubject<(OtherUserProfileModel, PostListModel)>()
        let followOrUnfollowSuccessTrigger = PublishSubject<Void>()
        
        input.reload
            .flatMap {
                Observable.zip(
                    NetworkManager.shared.otherUserProfileCheck(userId: input.userId).asObservable(),
                    NetworkManager.shared.postCheckUser(userId: input.userId).asObservable()
                ).map { profileResult, postResult -> (NetworkResult<OtherUserProfileModel>, NetworkResult<PostListModel>) in
                    return (profileResult, postResult)
                }
            }
            .debug("다른 유저 프로필 및 포스트 조회")
            .subscribe(with: self) { owner, value in
                switch (value.0, value.1) {
                case (.success(let profileModel), .success(let postListModel)): result.onNext((profileModel, postListModel))
                case (.error(let profileError), _): print(profileError)
                case (_, .error(let postError)): print(postError)
                }
            }.disposed(by: disposeBag)
        
        input.followStatus
            .flatMap { status in
                status ? NetworkManager.shared.unfollow(userId: input.userId) : NetworkManager.shared.follow(userId: input.userId)
            }
            .debug("팔로우 및 언팔로우")
            .subscribe(with: self) { owner, value in
                switch value {
                case .success(_): followOrUnfollowSuccessTrigger.onNext(())
                case .error(let error): print(error)
                }
            }.disposed(by: disposeBag)
        
        return Output(result: result, followOrUnfollowSuccessTrigger: followOrUnfollowSuccessTrigger.asDriver(onErrorJustReturn: ()))
    }
}
