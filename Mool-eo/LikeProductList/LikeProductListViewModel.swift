//
//  LikeProductListViewModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/1/24.
//

import Foundation
import RxSwift
import RxCocoa

final class LikeProductListViewModel: ViewModelType {
    var disposeBag: DisposeBag = DisposeBag()
    
    struct Input {
        let reload: BehaviorSubject<Void>
        let modelSelected: Observable<PostModel>
        let itemSelected: Observable<IndexPath>
        let lastItem: PublishSubject<Int>
        let nextCursor: PublishSubject<String>
        let prefetch: Observable<[IndexPath]>
    }
    
    struct Output {
        let likeProductList: PublishSubject<PostListModel>
        let nextLikeProductList: PublishSubject<PostListModel>
        let productDetail: Driver<String>
        let networkFail: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        let likeProductList = PublishSubject<PostListModel>()
        let prefetch = PublishSubject<Void>()
        let nextLikeProductList = PublishSubject<PostListModel>()
        let productDetail = PublishSubject<String>()
        let networkFail = PublishSubject<Void>()

        handleReload(input: input, likeProductList: likeProductList, networkFail: networkFail)
        handlePrefetch(input: input, prefetch: prefetch)
        handleNextLikePostList(input: input, prefetch: prefetch, nextLikeProductList: nextLikeProductList, networkFail: networkFail)
        handleProductDetail(input: input, productDetail: productDetail)

        
        return Output(likeProductList: likeProductList, 
                      nextLikeProductList: nextLikeProductList,
                      productDetail: productDetail.asDriver(onErrorJustReturn: ""),
                      networkFail: networkFail.asDriver(onErrorJustReturn: ()))
    }
    
    private func handleReload(input: Input, likeProductList: PublishSubject<PostListModel>, networkFail: PublishSubject<Void>) {
        input.reload
            .flatMap { NetworkManager.shared.likeProdcutCheck(limit: "15", next: "") }
            .subscribe(with: self) { owner, value in
                switch value {
                case .success(let postListModel): likeProductList.onNext(postListModel)
                case .error(let error): owner.handleNetworkError(error: error, networkFail: networkFail)
                }
            }
            .disposed(by: disposeBag)
    }
        
    private func handlePrefetch(input: Input, prefetch: PublishSubject<Void>) {
        Observable.combineLatest(input.prefetch.compactMap(\.last?.item), input.lastItem)
            .bind(with: self) { owner, value in
                guard value.0 >= value.1 - 1 else { return }
                prefetch.onNext(())
            }
            .disposed(by: disposeBag)
    }
    
    private func handleNextLikePostList(input: Input, prefetch: PublishSubject<Void>, nextLikeProductList: PublishSubject<PostListModel>, networkFail: PublishSubject<Void>) {
        Observable.zip(input.nextCursor, prefetch)
            .flatMap { NetworkManager.shared.likeProdcutCheck(limit: "15", next: $0.0) }
            .subscribe(with: self) { owner, value in
                switch value {
                case .success(let postListModel): nextLikeProductList.onNext(postListModel)
                case .error(let error): owner.handleNetworkError(error: error, networkFail: networkFail)
                }
            }
            .disposed(by: disposeBag)
    }
    
    private func handleProductDetail(input: Input, productDetail: PublishSubject<String>) {
        Observable.zip(input.modelSelected, input.itemSelected)
            .map { $0.0.postId }
            .bind(to: productDetail)
            .disposed(by: disposeBag)
    }
    
    private func handleNetworkError(error: NetworkError, networkFail: PublishSubject<Void>) {
        switch error {
        case .networkFail: networkFail.onNext(())
        default: print("⚠️OTHER ERROR : \(error)⚠️")
        }
    }
}
