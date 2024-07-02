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
        let reload: BehaviorSubject<(ProductIdentifier)>
        let userId: String
        let modelSelected: Observable<PostModel>
        let itemSelected: Observable<IndexPath>
        let lastItem: PublishSubject<Int>
        let nextCursor: PublishSubject<String>
        let prefetch: Observable<[IndexPath]>
    }
    
    struct Output {
        let productPostList: PublishSubject<PostListModel>
        let nextProductPostList: PublishSubject<PostListModel>
        let productPost: PublishSubject<PostModel>
        let networkFail: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        let productPostList = PublishSubject<PostListModel>()
        let nextProductPostList = PublishSubject<PostListModel>()
        let prefetch = PublishSubject<Void>()
        let productPost = PublishSubject<PostModel>()
        let networkFail = PublishSubject<Void>()
        
        // 게시글 조회 네트워크 통신 진행
        input.reload
            .flatMap { value in
                NetworkManager.shared.postCheckUser(userId: input.userId, productId: value.rawValue, limit: "20", next: "")
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
            .flatMap { (next, _) in
                NetworkManager.shared.postCheckUser(userId: input.userId, productId: ProductIdentifier.market.rawValue, limit: "12", next: next)
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
                      productPost: productPost,
                      networkFail: networkFail.asDriver(onErrorJustReturn: ()))
    }
}
