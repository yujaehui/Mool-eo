//
//  ProductListViewModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/10/24.
//

import Foundation
import RxSwift
import RxCocoa

final class ProductListViewModel: ViewModelType {
    
    var disposeBag: DisposeBag = DisposeBag()
    
    struct Input {
        let categoryModelSelected: Observable<String>
        let categoryItemSelected: Observable<IndexPath>
        let reload: BehaviorSubject<Void>
        let lastItem: PublishSubject<Int>
        let nextCursor: PublishSubject<String>
        let prefetch: Observable<[IndexPath]>
        let modelSelected: Observable<PostModel>
        let itemSelected: Observable<IndexPath>
        let productWriteButtonTap: Observable<Void>
    }
    
    struct Output {
        let selectedCategory: BehaviorSubject<String>
        let productList: PublishSubject<PostListModel>
        let nextProductList: PublishSubject<PostListModel>
        let networkFail: Driver<Void>
        let productDetail: PublishSubject<PostModel>
        let productWriteButtonTap: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        let selectedCategory = BehaviorSubject<String>(value: Category.allCases[0].rawValue)
        let productList = PublishSubject<PostListModel>()
        let nextProductList = PublishSubject<PostListModel>()
        let prefetch = PublishSubject<Void>()
        let networkFail = PublishSubject<Void>()
        let productDetail = PublishSubject<PostModel>()
        
        Observable.zip(input.categoryModelSelected, input.categoryItemSelected)
            .map { $0.0 }
            .bind(with: self) { owner, value in
                selectedCategory.onNext(value)
            }.disposed(by: disposeBag)
        
        input.reload
            .withLatestFrom(selectedCategory)
            .flatMap { category in
                if category == "전체" {
                    NetworkManager.shared.postCheck(productId: ProductIdentifier.product.rawValue, limit: "12", next: "")
                } else {
                    NetworkManager.shared.hashtag(hashtag: HashtagManager.shared.replaceSpacesWithUnderscore(category), productId: ProductIdentifier.product.rawValue, limit: "12", next: "")
                }
            }
            .subscribe(with: self) { owner, value in
                switch value {
                case .success(let postListModel):
                    productList.onNext(postListModel)
                case .error(let error):
                    switch error {
                    case .networkFail: networkFail.onNext(())
                    default: print("⚠️OTHER ERROR : \(error)⚠️")
                    }
                }
            }.disposed(by: disposeBag)
        
        Observable.combineLatest(input.prefetch.compactMap(\.last?.row), input.lastItem)
            .bind(with: self) { owner, value in
                guard value.0 >= value.1 - 1 else { return }
                prefetch.onNext(())
            }.disposed(by: disposeBag)
        
        Observable.zip(input.nextCursor, prefetch)
            .withLatestFrom(selectedCategory) { nextPrefetch, categroy in
                return (nextPrefetch.0, nextPrefetch.1, categroy)
            }
            .flatMap { (next, _, category) in
                if category == "전체" {
                    NetworkManager.shared.postCheck(productId: ProductIdentifier.product.rawValue, limit: "12", next: next)
                } else {
                    NetworkManager.shared.hashtag(hashtag: HashtagManager.shared.replaceSpacesWithUnderscore(category), productId: ProductIdentifier.product.rawValue, limit: "12", next: next)
                }
            }
            .subscribe(with: self) { owner, value in
                switch value {
                case .success(let postListModel):
                    nextProductList.onNext(postListModel)
                case .error(let error):
                    switch error {
                    case .networkFail: networkFail.onNext(())
                    default: print("⚠️OTHER ERROR : \(error)⚠️")
                    }
                }
            }.disposed(by: disposeBag)
        
        Observable.zip(input.modelSelected, input.itemSelected)
            .map { $0.0 }
            .bind(with: self) { owner, value in
                productDetail.onNext(value)
            }.disposed(by: disposeBag)
        
        return Output(selectedCategory: selectedCategory,
                      productList: productList,
                      nextProductList: nextProductList,
                      networkFail: networkFail.asDriver(onErrorJustReturn: ()),
                      productDetail: productDetail,
                      productWriteButtonTap: input.productWriteButtonTap.asDriver(onErrorJustReturn: ()))
    }
}
