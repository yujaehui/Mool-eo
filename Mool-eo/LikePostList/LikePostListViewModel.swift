//
//  LikePostListViewModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/11/24.
//

import Foundation
import RxSwift
import RxCocoa

final class LikePostListViewModel: ViewModelType {
    var disposeBag: DisposeBag = DisposeBag()
    
    struct Input {
        let reload: BehaviorSubject<Void>
        let modelSelected: Observable<PostModel>
        let itemSelected: Observable<IndexPath>
        let lastRow: PublishSubject<Int>
        let nextCursor: PublishSubject<String>
        let prefetch: Observable<[IndexPath]>
    }
    
    struct Output {
        let likePostList: PublishSubject<PostListModel>
        let nextLikePostList: PublishSubject<PostListModel>
        let postDetail: Driver<String>
        let networkFail: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        let likePostList = PublishSubject<PostListModel>()
        let prefetch = PublishSubject<Void>()
        let nextLikePostList = PublishSubject<PostListModel>()
        let postDetail = PublishSubject<String>()
        let networkFail = PublishSubject<Void>()
        
        handleReload(input: input, likePostList: likePostList, networkFail: networkFail)
        handlePrefetch(input: input, prefetch: prefetch)
        handleNextLikePostList(input: input, prefetch: prefetch, nextLikePostList: nextLikePostList, networkFail: networkFail)
        handlePostDetail(input: input, postDetail: postDetail)
        
        return Output(likePostList: likePostList,
                      nextLikePostList: nextLikePostList,
                      postDetail: postDetail.asDriver(onErrorJustReturn: ""),
                      networkFail: networkFail.asDriver(onErrorJustReturn: ()))
    }
    
    private func handleReload(input: Input, likePostList: PublishSubject<PostListModel>, networkFail: PublishSubject<Void>) {
        input.reload
            .flatMap { NetworkManager.shared.likePostCheck(limit: "7", next: "") }
            .subscribe(with: self) { owner, value in
                switch value {
                case .success(let postListModel): likePostList.onNext(postListModel)
                case .error(let error): owner.handleNetworkError(error: error, networkFail: networkFail)
                }
            }
            .disposed(by: disposeBag)
    }
        
    private func handlePrefetch(input: Input, prefetch: PublishSubject<Void>) {
        Observable.combineLatest(input.prefetch.compactMap(\.last?.row), input.lastRow)
            .bind(with: self) { owner, value in
                guard value.0 == value.1 else { return }
                prefetch.onNext(())
            }
            .disposed(by: disposeBag)
    }
    
    private func handleNextLikePostList(input: Input, prefetch: PublishSubject<Void>, nextLikePostList: PublishSubject<PostListModel>, networkFail: PublishSubject<Void>) {
        Observable.zip(input.nextCursor, prefetch)
            .flatMap { NetworkManager.shared.likePostCheck(limit: "7", next: $0.0) }
            .subscribe(with: self) { owner, value in
                switch value {
                case .success(let postListModel): nextLikePostList.onNext(postListModel)
                case .error(let error): owner.handleNetworkError(error: error, networkFail: networkFail)
                }
            }
            .disposed(by: disposeBag)
    }
    
    private func handlePostDetail(input: Input, postDetail: PublishSubject<String>) {
        Observable.zip(input.modelSelected, input.itemSelected)
            .map { $0.0.postId }
            .bind(to: postDetail)
            .disposed(by: disposeBag)
    }
    
    private func handleNetworkError(error: NetworkError, networkFail: PublishSubject<Void>) {
        switch error {
        case .networkFail: networkFail.onNext(())
        default: print("⚠️OTHER ERROR : \(error)⚠️")
        }
    }
}
