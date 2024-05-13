//
//  LikeProductListViewModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/1/24.
//

import Foundation
import RxSwift
import RxCocoa

class LikeProductListViewModel: ViewModelType {
    var disposeBag: DisposeBag = DisposeBag()
    
    struct Input {
        let reload: BehaviorSubject<Void>
        let modelSelected: Observable<PostModel>
        let itemSelected: Observable<IndexPath>
        let lastItem: PublishSubject<Int>
        let prefetch: Observable<[IndexPath]>
        let nextCursor: PublishSubject<String>
    }
    
    struct Output {
        let likeProductList: PublishSubject<PostListModel>
        let nextLikeProductList: PublishSubject<PostListModel>
        let post: Driver<String>
        let networkFail: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        let likeProductList = PublishSubject<PostListModel>()
        let nextLikeProductList = PublishSubject<PostListModel>()
        let prefetch = PublishSubject<Void>()
        let post = PublishSubject<String>()
        let networkFail = PublishSubject<Void>()
        
        input.reload
            .flatMap { _ in
                NetworkManager.shared.likeProdcutCheck(limit: "7", next: "")
            }
            .subscribe(with: self) { owner, value in
                switch value {
                case .success(let postListModel):
                    likeProductList.onNext(postListModel)
                case .error(let error):
                    switch error {
                    case .networkFail: networkFail.onNext(())
                    default: print("⚠️OTHER ERROR : \(error)⚠️")
                    }
                }
            }.disposed(by: disposeBag)
        
        // Pagination
        let prefetchObservable = Observable.combineLatest(input.prefetch.compactMap(\.last?.item), input.lastItem)
        
        prefetchObservable
            .bind(with: self) { owner, value in
                guard value.0 == value.1 else { return }
                prefetch.onNext(())
            }.disposed(by: disposeBag)
        
        let nextPrefetch = Observable.zip(input.nextCursor, prefetch)
        
        nextPrefetch
            .flatMap { (next, _) in
                NetworkManager.shared.likeProdcutCheck(limit: "7", next: next)
            }
            .debug("🔥Pagination🔥")
            .subscribe(with: self) { owner, value in
                switch value {
                case .success(let postListModel):
                    nextLikeProductList.onNext(postListModel)
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
        
        return Output(likeProductList: likeProductList, 
                      nextLikeProductList: nextLikeProductList,
                      post: post.asDriver(onErrorJustReturn: ""),
                      networkFail: networkFail.asDriver(onErrorJustReturn: ()))
    }
}
