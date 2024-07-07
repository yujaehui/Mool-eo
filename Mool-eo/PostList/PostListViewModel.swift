//
//  PostListViewModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/20/24.
//

import Foundation
import RxSwift
import RxCocoa

final class PostListViewModel: ViewModelType {
    var disposeBag: DisposeBag = DisposeBag()
    
    struct Input {
        let reload: BehaviorSubject<Void>
        let lastRow: PublishSubject<Int>
        let nextCursor: PublishSubject<String>
        let prefetch: Observable<[IndexPath]>
        let modelSelected: Observable<PostModel>
        let itemSelected: Observable<IndexPath>
        let postWriteButtonTap: Observable<Void>
    }
    
    struct Output {
        let postList: PublishSubject<PostListModel>
        let nextPostList: PublishSubject<PostListModel>
        let postDetail: PublishSubject<PostModel>
        let postWriteButtonTap: Driver<Void>
        let networkFail: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        let postList = PublishSubject<PostListModel>()
        let nextPostList = PublishSubject<PostListModel>()
        let prefetch = PublishSubject<Void>()
        let postDetail = PublishSubject<PostModel>()
        let networkFail = PublishSubject<Void>()
        
        input.reload
            .flatMap { value in
                NetworkManager.shared.postCheck(productId: ProductIdentifier.post.rawValue, limit: "10", next: "")
            }
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
        
        
        Observable.combineLatest(input.prefetch.compactMap(\.last?.row), input.lastRow)
            .bind(with: self) { owner, value in
                guard value.0 == value.1 else { return }
                prefetch.onNext(())
            }.disposed(by: disposeBag)
                
        Observable.zip(input.nextCursor, prefetch)
            .flatMap { (next, _) in
                NetworkManager.shared.postCheck(productId: ProductIdentifier.post.rawValue, limit: "10", next: next)
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
            .map { $0.0 }
            .bind(with: self) { owner, value in
                postDetail.onNext(value)
            }.disposed(by: disposeBag)
        
        return Output(postList: postList,
                      nextPostList: nextPostList,
                      postDetail: postDetail,
                      postWriteButtonTap: input.postWriteButtonTap.asDriver(onErrorJustReturn: ()),
                      networkFail: networkFail.asDriver(onErrorJustReturn: ()))
    }
}
