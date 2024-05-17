//
//  ProfilePostListViewModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/16/24.
//

import Foundation
import RxSwift
import RxCocoa

class ProfilePostListViewModel: ViewModelType {
    var disposeBag: DisposeBag = DisposeBag()
    
    struct Input {
        let reload: BehaviorSubject<ProductIdentifier>
        let userId: String
        let modelSelected: Observable<PostModel>
        let itemSelected: Observable<IndexPath>
        let lastRow: PublishSubject<Int>
        let prefetch: Observable<[IndexPath]>
        let postBoard: ProductIdentifier
        let nextCursor: PublishSubject<String>
    }
    
    struct Output {
        let postList: PublishSubject<PostListModel>
        let nextPostList: PublishSubject<PostListModel>
        let post: Driver<String>
        let networkFail: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        let postList = PublishSubject<PostListModel>()
        let nextPostList = PublishSubject<PostListModel>()
        let prefetch = PublishSubject<Void>()
        let post = PublishSubject<String>()
        let networkFail = PublishSubject<Void>()
        
        // 게시글 조회 네트워크 통신 진행
        input.reload
            .flatMap { value in
                NetworkManager.shared.postCheckUser(userId: input.userId, productId: value.rawValue, limit: "10", next: "")
            }
            .debug("게시글 조회")
            .subscribe(with: self) { owner, value in
                switch value {
                case .success(let postListModel):
                    postList.onNext(postListModel)
                case .error(let error):
                    switch error {
                    case .networkFail: networkFail.onNext(())
                    default: print("⚠️OTHER ERROR : \(error)⚠️")
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
                NetworkManager.shared.postCheckUser(userId: input.userId, productId: input.postBoard.rawValue, limit: "10", next: next)
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
            .map { $0.0.postId }
            .bind(with: self) { owner, value in
                post.onNext(value)
            }.disposed(by: disposeBag)
        
        return Output(postList: postList,
                      nextPostList: nextPostList,
                      post: post.asDriver(onErrorJustReturn: ""),
                      networkFail: networkFail.asDriver(onErrorJustReturn: ()))
    }
}
