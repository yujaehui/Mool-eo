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
        let modelSelected: Observable<OtherUserProfileSectionItem>
        let itemSelected: Observable<IndexPath>
        let userId: String
        let followStatus: PublishSubject<Bool>
    }
    
    struct Output {
        let result: PublishSubject<(OtherUserProfileModel, PostListModel, PostListModel)>
        let post: PublishSubject<PostModel>
        let followOrUnfollowSuccessTrigger: Driver<Void>
        let notFoundErr: Driver<Void>
        let networkFail: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        let result = PublishSubject<(OtherUserProfileModel, PostListModel, PostListModel)>()
        let post = PublishSubject<PostModel>()
        let followOrUnfollowSuccessTrigger = PublishSubject<Void>()
        let notFoundErr = PublishSubject<Void>()
        let networkFail = PublishSubject<Void>()
        
        input.reload
            .flatMap {
                Observable.zip(
                    NetworkManager.shared.otherUserProfileCheck(userId: input.userId).asObservable(),
                    NetworkManager.shared.postCheckUser(userId: input.userId, productId: ProductIdentifier.product.rawValue, limit: "10", next: "").asObservable(),
                    NetworkManager.shared.postCheckUser(userId: input.userId, productId: ProductIdentifier.post.rawValue, limit: "10", next: "").asObservable()
                ).map { profileResult, postResult, productPostResult -> (NetworkResult<OtherUserProfileModel>, NetworkResult<PostListModel>, NetworkResult<PostListModel>) in
                    return (profileResult, postResult, productPostResult)
                }
            }
            .debug("다른 유저 프로필 및 포스트 조회")
            .subscribe(with: self) { owner, value in
                switch (value.0, value.1, value.2) {
                case (.success(let profileModel), .success(let productModel), .success(let postModel)):
                    result.onNext((profileModel, productModel, postModel))
                case (.error(let profileError), _, _):
                    switch profileError {
                    case .networkFail: networkFail.onNext(())
                    default: print("⚠️OTHER ERROR : \(profileError)⚠️")
                    }
                case (_, .error(let productError), _):
                    switch productError {
                    case .networkFail: networkFail.onNext(())
                    default: print("⚠️OTHER ERROR : \(productError)⚠️")
                    }
                case (_, _, .error(let postError)):
                    switch postError {
                    case .networkFail: networkFail.onNext(())
                    default: print("⚠️OTHER ERROR : \(postError)⚠️")
                    }
                }
            }.disposed(by: disposeBag)
        
        Observable.zip(input.modelSelected, input.itemSelected)
            .bind(with: self) { owner, value in
                switch value.0 {
                case .product(let myPost): post.onNext(myPost)
                default: break
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
                case .error(let error):
                    switch error {
                    case .notFoundErr: notFoundErr.onNext(())
                    case .networkFail: networkFail.onNext(())
                    default: print("⚠️OTHER ERROR : \(error)⚠️")
                    }
                }
            }.disposed(by: disposeBag)
        
        return Output(result: result, 
                      post: post,
                      followOrUnfollowSuccessTrigger: followOrUnfollowSuccessTrigger.asDriver(onErrorJustReturn: ()),
                      notFoundErr: notFoundErr.asDriver(onErrorJustReturn: ()),
                      networkFail: networkFail.asDriver(onErrorJustReturn: ()))
    }
}
