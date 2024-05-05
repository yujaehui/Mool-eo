//
//  ScrapPostListViewModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/1/24.
//

import Foundation
import RxSwift
import RxCocoa

class ScrapPostListViewModel: ViewModelType {
    var disposeBag: DisposeBag = DisposeBag()
    
    struct Input {
        let reload: BehaviorSubject<Void>
        let modelSelected: Observable<PostModel>
        let itemSelected: Observable<IndexPath>
        let lastRow: PublishSubject<Int>
        let prefetch: Observable<[IndexPath]>
        let nextCursor: PublishSubject<String>
    }
    
    struct Output {
        let scrapPostList: PublishSubject<PostListModel>
        let nextScrapPostList: PublishSubject<PostListModel>
        let post: Driver<String>
        let forbidden: Driver<Void>
        let badRequest: Driver<Void>
        let networkFail: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        let scrapPostList = PublishSubject<PostListModel>()
        let nextScrapPostList = PublishSubject<PostListModel>()
        let prefetch = PublishSubject<Void>()
        let post = PublishSubject<String>()
        let forbidden = PublishSubject<Void>()
        let badRequest = PublishSubject<Void>()
        let networkFail = PublishSubject<Void>()
        
        input.reload
            .flatMap { _ in
                NetworkManager.shared.scrapPostCheck(limit: "7", next: "")
            }
            .debug("스크랩 게시물 조회")
            .subscribe(with: self) { owner, value in
                switch value {
                case .success(let postListModel):
                    scrapPostList.onNext(postListModel)
                case .error(let error):
                    switch error {
                    case .forbidden: forbidden.onNext(())
                    case .badRequest: badRequest.onNext(())
                    default: print("⚠️OTHER ERROR : \(error)⚠️")
                    }
                }
            } onError: { owner, error in
                print("🛰️NETWORK ERROR : \(error)🛰️")
                networkFail.onNext(())
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
                NetworkManager.shared.scrapPostCheck(limit: "7", next: next)
            }
            .debug("🔥Pagination🔥")
            .subscribe(with: self) { owner, value in
                switch value {
                case .success(let postListModel):
                    nextScrapPostList.onNext(postListModel)
                case .error(let error):
                    switch error {
                    case .forbidden: forbidden.onNext(())
                    case .badRequest: badRequest.onNext(())
                    default: print("⚠️OTHER ERROR : \(error)⚠️")
                    }
                }
            } onError: { owner, error in
                print("🛰️NETWORK ERROR : \(error)🛰️")
                networkFail.onNext(())
            }.disposed(by: disposeBag)
        
        Observable.zip(input.modelSelected, input.itemSelected)
            .map { $0.0.postID }
            .bind(with: self) { owner, value in
                post.onNext(value)
            }.disposed(by: disposeBag)
        
        return Output(scrapPostList: scrapPostList, 
                      nextScrapPostList: nextScrapPostList,
                      post: post.asDriver(onErrorJustReturn: ""),
                      forbidden: forbidden.asDriver(onErrorJustReturn: ()),
                      badRequest: badRequest.asDriver(onErrorJustReturn: ()),
                      networkFail: networkFail.asDriver(onErrorJustReturn: ()))
    }
}
