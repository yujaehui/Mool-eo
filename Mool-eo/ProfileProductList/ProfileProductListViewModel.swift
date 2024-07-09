//
//  ProfileProductListViewModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 7/2/24.
//

import Foundation
import RxSwift
import RxCocoa

final class ProfileProductListViewModel: ViewModelType {
    
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
        let productList: PublishSubject<PostListModel>
        let nextProductList: PublishSubject<PostListModel>
        let productDetail: PublishSubject<PostModel>
        let networkFail: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        let productList = PublishSubject<PostListModel>()
        let prefetch = PublishSubject<Void>()
        let nextProductList = PublishSubject<PostListModel>()
        let productDetail = PublishSubject<PostModel>()
        let networkFail = PublishSubject<Void>()
        
        handleReload(input: input, productList: productList, networkFail: networkFail)
        handlePrefetch(input: input, prefetch: prefetch)
        handleNextProductList(input: input, prefetch: prefetch, nextProductList: nextProductList, networkFail: networkFail)
        handleProductDetail(input: input, productDetail: productDetail)
        
        return Output(productList: productList,
                      nextProductList: nextProductList,
                      productDetail: productDetail,
                      networkFail: networkFail.asDriver(onErrorJustReturn: ()))
    }
    
    private func handleReload(input: Input, productList: PublishSubject<PostListModel>, networkFail: PublishSubject<Void>) {
        input.reload
            .flatMap { NetworkManager.shared.postCheckUser(userId: input.userId, productId: ProductIdentifier.product.rawValue, limit: "10", next: "") }
            .subscribe(with: self) { owner, value in
                switch value {
                case .success(let postListModel): productList.onNext(postListModel)
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
    
    private func handleNextProductList(input: Input, prefetch: PublishSubject<Void>, nextProductList: PublishSubject<PostListModel>, networkFail: PublishSubject<Void>) {
        Observable.zip(input.nextCursor, prefetch)
            .flatMap { NetworkManager.shared.postCheckUser(userId: input.userId, productId: ProductIdentifier.product.rawValue, limit: "10", next: $0.0) }
            .subscribe(with: self) { owner, value in
                switch value {
                case .success(let postListModel): nextProductList.onNext(postListModel)
                case .error(let error): owner.handleNetworkError(error: error, networkFail: networkFail)
                }
            }
            .disposed(by: disposeBag)
    }
    
    private func handleProductDetail(input: Input, productDetail: PublishSubject<PostModel>) {
        Observable.zip(input.modelSelected, input.itemSelected)
            .map { $0.0 }
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
