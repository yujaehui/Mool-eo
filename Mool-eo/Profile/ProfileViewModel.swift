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
        let result: PublishSubject<(ProfileModel, PostListModel)>
        let nextPostList: PublishSubject<PostListModel>
        let post: PublishSubject<PostModel>
        let networkFail: Driver<Void>
        let settingButtonTap: PublishSubject<Void>
    }
    
    func transform(input: Input) -> Output {
        let result = PublishSubject<(ProfileModel, PostListModel)>()
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
                    NetworkManager.shared.postCheckUser(userId: userId, productId: ProductIdentifier.market.rawValue, limit: "10", next: "").asObservable()
                ).map { profileResult, postResult -> (NetworkResult<ProfileModel>, NetworkResult<PostListModel>) in
                    return (profileResult, postResult)
                }
            }
            .debug("프로필 및 유저 포스트 조회")
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
                case .infoItem( _): break
                }
            }.disposed(by: disposeBag)
        

        
        return Output(result: result,
                      nextPostList: nextPostList,
                      post: post,
                      networkFail: networkFail.asDriver(onErrorJustReturn: ()),
                      settingButtonTap: input.settingButtonTap)
    }
}
