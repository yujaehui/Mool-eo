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
        let modelSelected: Observable<ProfileSectionItem>
        let itemSelected: Observable<IndexPath>
        let withdrawButtonTap: Observable<Void>
    }
    
    struct Output {
        let result: PublishSubject<(ProfileModel, PostListModel)>
        let post: Driver<String>
        let withdrawSuccessTrigger: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        let result = PublishSubject<(ProfileModel, PostListModel)>()
        let post = PublishSubject<String>()
        let withdrawSuccessTrigger = PublishSubject<Void>()
        
        input.viewDidLoad
            .map {
                return UserDefaultsManager.userId!
            }
            .flatMap { userId in
                Observable.zip(
                    NetworkManager.shared.profileCheck().asObservable(),
                    NetworkManager.shared.postCheckUser(userId: userId).asObservable()
                ).map { profileResult, postResult -> (NetworkResult<ProfileModel>, NetworkResult<PostListModel>) in
                    return (profileResult, postResult)
                }
            }
            .debug("프로필 및 유저 포스트 조회")
            .subscribe(with: self) { owner, value in
                switch (value.0, value.1) {
                case (.success(let profileModel), .success(let postListModel)): result.onNext((profileModel, postListModel))
                case (.error(let profileError), _): print(profileError)
                case (_, .error(let postError)): print(postError)
                }
            }.disposed(by: disposeBag)
        
        
        Observable.zip(input.modelSelected, input.itemSelected)
            .bind(with: self) { owner, value in
                switch value.0 {
                case .myPostItem(let myPost): post.onNext(myPost.postID)
                case .infoItem( _): break
                }
            }.disposed(by: disposeBag)
        
        input.withdrawButtonTap
            .flatMap { _ in
                NetworkManager.shared.withdraw()
            }
            .debug("탈퇴")
            .subscribe(with: self) { owner, value in
                switch value {
                case .success(_): withdrawSuccessTrigger.onNext(())
                case .error(let error):
                    switch error {
                    default: print("error")
                    }
                }
            }.disposed(by: disposeBag)
        
        return Output(result: result,
                      post: post.asDriver(onErrorJustReturn: ""),
                      withdrawSuccessTrigger: withdrawSuccessTrigger.asDriver(onErrorJustReturn: ()))
    }
}
