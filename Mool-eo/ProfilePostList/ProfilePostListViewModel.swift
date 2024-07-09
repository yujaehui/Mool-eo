//
//  ProfilePostListViewModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/16/24.
//

import Foundation
import RxSwift
import RxCocoa

final class ProfilePostListViewModel: ViewModelType {
    var disposeBag: DisposeBag = DisposeBag()
    
    struct Input {
        let reload: BehaviorSubject<Void>
        let userId: String
        let modelSelected: Observable<PostModel>
        let itemSelected: Observable<IndexPath>
        let lastRow: PublishSubject<Int>
        let nextCursor: PublishSubject<String>
        let prefetch: Observable<[IndexPath]>
    }
    
    struct Output {
        let postList: PublishSubject<PostListModel>
        let nextPostList: PublishSubject<PostListModel>
        let postDetail: PublishSubject<PostModel>
        let networkFail: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        let postList = PublishSubject<PostListModel>()
        let nextPostList = PublishSubject<PostListModel>()
        let prefetch = PublishSubject<Void>()
        let postDetail = PublishSubject<PostModel>()
        let networkFail = PublishSubject<Void>()
        
        handleReload(input: input, postList: postList, networkFail: networkFail)
        handlePrefetch(input: input, prefetch: prefetch)
        handleNextProductList(input: input, prefetch: prefetch, nextPostList: nextPostList, networkFail: networkFail)
        handlePostDetail(input: input, postDetail: postDetail)
        
        return Output(postList: postList,
                      nextPostList: nextPostList,
                      postDetail: postDetail,
                      networkFail: networkFail.asDriver(onErrorJustReturn: ()))
    }
    
    private func handleReload(input: Input, postList: PublishSubject<PostListModel>, networkFail: PublishSubject<Void>) {
        input.reload
            .flatMap { NetworkManager.shared.postCheckUser(userId: input.userId, productId: ProductIdentifier.post.rawValue, limit: "10", next: "") }
            .subscribe(with: self) { owner, value in
                switch value {
                case .success(let postListModel): postList.onNext(postListModel)
                case .error(let error): owner.handleNetworkError(error: error, networkFail: networkFail)
                }
            }
            .disposed(by: disposeBag)
    }

    private func handlePrefetch(input: Input, prefetch: PublishSubject<Void>) {
        Observable.combineLatest(input.prefetch.compactMap(\.last?.row), input.lastRow)
            .bind(with: self) { owner, value in
                guard value.0 >= value.1 - 1 else { return }
                prefetch.onNext(())
            }
            .disposed(by: disposeBag)
    }
    
    private func handleNextProductList(input: Input, prefetch: PublishSubject<Void>, nextPostList: PublishSubject<PostListModel>, networkFail: PublishSubject<Void>) {
        Observable.zip(input.nextCursor, prefetch)
            .flatMap { NetworkManager.shared.postCheckUser(userId: input.userId, productId: ProductIdentifier.post.rawValue, limit: "10", next: $0.0) }
            .subscribe(with: self) { owner, value in
                switch value {
                case .success(let postListModel): nextPostList.onNext(postListModel)
                case .error(let error): owner.handleNetworkError(error: error, networkFail: networkFail)
                }
            }
            .disposed(by: disposeBag)
    }
    
    private func handlePostDetail(input: Input, postDetail: PublishSubject<PostModel>) {
        Observable.zip(input.modelSelected, input.itemSelected)
            .map { $0.0 }
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
