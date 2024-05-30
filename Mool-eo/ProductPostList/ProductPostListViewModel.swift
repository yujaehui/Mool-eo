//
//  ProductPostListViewModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/10/24.
//

import Foundation
import RxSwift
import RxCocoa

class ProductPostListViewModel: ViewModelType {
    
    var disposeBag: DisposeBag = DisposeBag()
    
    struct Input {
        let reload: BehaviorSubject<(ProductIdentifier)>
        let postWriteButtonTap: Observable<Void>
        let category: BehaviorSubject<String>
        let categoryModelSelected: Observable<String>
        let categoryItemSelected: Observable<IndexPath>
        let modelSelected: Observable<PostModel>
        let itemSelected: Observable<IndexPath>
        let lastItem: PublishSubject<Int>
        let nextCursor: PublishSubject<String>
        let prefetch: Observable<[IndexPath]>
    }
    
    struct Output {
        let productPostList: PublishSubject<PostListModel>
        let nextProductPostList: PublishSubject<PostListModel>
        let postWriteButtonTap: Driver<Void>
        let productPost: PublishSubject<PostModel>
        let networkFail: Driver<Void>
        let selectedCategory: PublishSubject<String>
    }
    
    func transform(input: Input) -> Output {
        let productPostList = PublishSubject<PostListModel>()
        let nextProductPostList = PublishSubject<PostListModel>()
        let prefetch = PublishSubject<Void>()
        let productPost = PublishSubject<PostModel>()
        let networkFail = PublishSubject<Void>()
        let selectedCategory = PublishSubject<String>()
        
        Observable.zip(input.categoryModelSelected, input.categoryItemSelected)
            .map { $0.0 }
            .bind(with: self) { owner, value in
                selectedCategory.onNext(value)
            }.disposed(by: disposeBag)
        
        // 게시글 조회 네트워크 통신 진행
        input.reload
            .withLatestFrom(input.category) { productId, category in
                return (productId, category)
            }
            .flatMap { value in
                if value.1 == "전체" {
                    NetworkManager.shared.postCheck(productId: value.0.rawValue, limit: "12", next: "")
                } else {
                    NetworkManager.shared.hashtag(hashtag: HashtagManager.shared.replaceSpacesWithUnderscore(value.1), productId: value.0.rawValue, limit: "12", next: "")
                }
            }
            .debug("게시글 조회")
            .subscribe(with: self) { owner, value in
                switch value {
                case .success(let postListModel):
                    productPostList.onNext(postListModel)
                case .error(let error):
                    switch error {
                    case .networkFail: networkFail.onNext(())
                    default: print("⚠️OTHER ERROR : \(error)⚠️")
                    }
                }
            }.disposed(by: disposeBag)
        
        // Pagination
        let prefetchObservable = Observable.combineLatest(input.prefetch.compactMap(\.last?.row), input.lastItem)
        
        prefetchObservable
            .bind(with: self) { owner, value in
                print(value)
                guard value.0 >= value.1 - 1 else { return }
                prefetch.onNext(())
            }.disposed(by: disposeBag)
        
        let nextPrefetch = Observable.zip(input.nextCursor, prefetch)
        
        nextPrefetch
            .withLatestFrom(input.category) { nextPrefetch, categroy in
                return (nextPrefetch.0, nextPrefetch.1, categroy)
            }
            .flatMap { (next, _, category) in
                if category == "전체" {
                    NetworkManager.shared.postCheck(productId: ProductIdentifier.market.rawValue, limit: "12", next: next)
                } else {
                    NetworkManager.shared.hashtag(hashtag: HashtagManager.shared.replaceSpacesWithUnderscore(category), productId: ProductIdentifier.market.rawValue, limit: "12", next: next)
                }
            }
            .debug("🔥Pagination🔥")
            .subscribe(with: self) { owner, value in
                switch value {
                case .success(let postListModel):
                    nextProductPostList.onNext(postListModel)
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
                productPost.onNext(value)
            }.disposed(by: disposeBag)
        
        return Output(productPostList: productPostList,
                      nextProductPostList: nextProductPostList,
                      postWriteButtonTap: input.postWriteButtonTap.asDriver(onErrorJustReturn: ()),
                      productPost: productPost,
                      networkFail: networkFail.asDriver(onErrorJustReturn: ()),
                      selectedCategory: selectedCategory)
    }
}
