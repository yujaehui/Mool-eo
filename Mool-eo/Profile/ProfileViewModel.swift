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
        let reload: BehaviorSubject<Void>
        let modelSelected: Observable<ProfileSectionItem>
        let itemSelected: Observable<IndexPath>
        let lastRow: PublishSubject<Int>
        let prefetch: Observable<[IndexPath]>
        let nextCursor: PublishSubject<String>
        let settingButtonTap: PublishSubject<Void>
    }
    
    struct Output {
        let result: PublishSubject<(ProfileModel, PostListModel, PostListModel)>
        let nextPostList: PublishSubject<PostListModel>
        let post: PublishSubject<PostModel>
        let networkFail: Driver<Void>
        let settingButtonTap: PublishSubject<Void>
    }
    
    func transform(input: Input) -> Output {
        let result = PublishSubject<(ProfileModel, PostListModel, PostListModel)>()
        let nextPostList = PublishSubject<PostListModel>()
        let prefetch = PublishSubject<Void>()
        let post = PublishSubject<PostModel>()
        let networkFail = PublishSubject<Void>()
        
        input.reload
            .map {
                return UserDefaultsManager.userId!
            }
            .flatMap { userId in
                Observable.zip(
                    NetworkManager.shared.profileCheck().asObservable(),
                    NetworkManager.shared.postCheckUser(userId: userId, productId: ProductIdentifier.postBoard.rawValue, limit: "9", next: "").asObservable(),
                    NetworkManager.shared.postCheckUser(userId: userId, productId: ProductIdentifier.market.rawValue, limit: "10", next: "").asObservable()
                ).map { profileResult, postResult, productPostResult -> (NetworkResult<ProfileModel>, NetworkResult<PostListModel>, NetworkResult<PostListModel>) in
                    return (profileResult, postResult, productPostResult)
                }
            }
            .debug("프로필 및 유저 포스트 조회")
            .subscribe(with: self) { owner, value in
                switch (value.0, value.1, value.2) {
                case (.success(let profileModel), .success(let postListModel), .success(let productPostListModel)):
                    result.onNext((profileModel, postListModel, productPostListModel))
                case (.error(let profileError), _, _):
                    switch profileError {
                    case .networkFail: networkFail.onNext(())
                    default: print("⚠️OTHER ERROR : \(profileError)⚠️")
                    }
                case (_, .error(let postError), _):
                    switch postError {
                    case .networkFail: networkFail.onNext(())
                    default: print("⚠️OTHER ERROR : \(postError)⚠️")
                    }
                case (_, _, .error(let productPostError)):
                    switch productPostError {
                    case .networkFail: networkFail.onNext(())
                    default: print("⚠️OTHER ERROR : \(productPostError)⚠️")
                    }
                }
            }.disposed(by: disposeBag)
        
        // Pagination
        let prefetchObservable = Observable.combineLatest(input.prefetch.compactMap(\.last?.item), input.lastRow)
        
        prefetchObservable
            .bind(with: self) { owner, value in
                print(value)
                guard value.0 >= value.1 - 1 else { return }
                prefetch.onNext(())
            }.disposed(by: disposeBag)
        
        let nextPrefetch = Observable.zip(input.nextCursor, prefetch)
        
        nextPrefetch
            .flatMap { (next, _) in
                NetworkManager.shared.postCheckUser(userId: UserDefaultsManager.userId!, productId: ProductIdentifier.market.rawValue, limit: "10", next: next)
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
                default: break
                }
            }.disposed(by: disposeBag)
        

        
        return Output(result: result,
                      nextPostList: nextPostList,
                      post: post,
                      networkFail: networkFail.asDriver(onErrorJustReturn: ()),
                      settingButtonTap: input.settingButtonTap)
    }
}
