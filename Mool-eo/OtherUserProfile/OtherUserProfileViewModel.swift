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
        let lastRow: PublishSubject<Int>
        let prefetch: Observable<[IndexPath]>
        let nextCursor: PublishSubject<String>
    }
    
    struct Output {
        let result: PublishSubject<(OtherUserProfileModel, PostListModel)>
        let nextPostList: PublishSubject<PostListModel>
        let post: PublishSubject<PostModel>
        let followOrUnfollowSuccessTrigger: Driver<Void>
        let notFoundErr: Driver<Void>
        let networkFail: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        let result = PublishSubject<(OtherUserProfileModel, PostListModel)>()
        let nextPostList = PublishSubject<PostListModel>()
        let prefetch = PublishSubject<Void>()
        let post = PublishSubject<PostModel>()
        let followOrUnfollowSuccessTrigger = PublishSubject<Void>()
        let notFoundErr = PublishSubject<Void>()
        let networkFail = PublishSubject<Void>()
        
        input.reload
            .flatMap {
                Observable.zip(
                    NetworkManager.shared.otherUserProfileCheck(userId: input.userId).asObservable(),
                    NetworkManager.shared.postCheckUser(userId: input.userId, productId: ProductIdentifier.market.rawValue, limit: "10", next: "").asObservable()
                ).map { profileResult, postResult -> (NetworkResult<OtherUserProfileModel>, NetworkResult<PostListModel>) in
                    return (profileResult, postResult)
                }
            }
            .debug("다른 유저 프로필 및 포스트 조회")
            .subscribe(with: self) { owner, value in
                switch (value.0, value.1) {
                case (.success(let profileModel), .success(let postListModel)): result.onNext((profileModel, postListModel))
                case (.error(let profileError), _):
                    switch profileError {
                    case .networkFail: networkFail.onNext(())
                    default: print("⚠️OTHER ERROR : \(profileError)⚠️")
                    }
                case (_, .error(let postError)):
                    switch postError {
                    case .networkFail: networkFail.onNext(())
                    default: print("⚠️OTHER ERROR : \(postError)⚠️")
                    }
                }
            }.disposed(by: disposeBag)
        
        // Pagination
        let prefetchObservable = Observable.combineLatest(input.prefetch.compactMap(\.last?.row), input.lastRow)
        
        prefetchObservable
            .bind(with: self) { owner, value in
                guard value.0 == value.1 else { return }
                prefetch.onNext(())
            }.disposed(by: disposeBag)
        
        let nextPrefetch = Observable.zip(input.nextCursor, prefetch)
        
        nextPrefetch
            .flatMap { (next, _) in
                NetworkManager.shared.postCheckUser(userId: input.userId, productId: ProductIdentifier.market.rawValue, limit: "10", next: next)
            }
            .debug("🔥Pagination🔥")
            .subscribe(with: self) { owner, value in
                switch value {
                case .success(let postListModel):
                    nextPostList.onNext(postListModel)
                case .error(let error):
                    switch error {
                    case .networkFail: networkFail.onNext(())
                    default: print("⚠️OTHER ERROR : \(error)⚠️")
                    }
                }
            }.disposed(by: disposeBag)
        
        Observable.zip(input.modelSelected, input.itemSelected)
            .bind(with: self) { owner, value in
                switch value.0 {
                case .product(let myPost): post.onNext(myPost)
                case .infoItem( _): break
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
                      nextPostList: nextPostList,
                      post: post,
                      followOrUnfollowSuccessTrigger: followOrUnfollowSuccessTrigger.asDriver(onErrorJustReturn: ()),
                      notFoundErr: notFoundErr.asDriver(onErrorJustReturn: ()),
                      networkFail: networkFail.asDriver(onErrorJustReturn: ()))
    }
}
