//
//  MyProductViewModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/27/24.
//

import Foundation
import RxSwift
import RxCocoa

class MyProductViewModel: ViewModelType {
    var disposeBag: DisposeBag = DisposeBag()
    
    struct Input {
        let reload: BehaviorSubject<Void>
        let lastItem: PublishSubject<Int>
        let nextCursor: PublishSubject<String>
        let prefetch: Observable<[IndexPath]>
    }
    
    struct Output {
        let result: PublishSubject<PostListModel>
        let nextPostList: PublishSubject<PostListModel>
        let networkFail: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        let result = PublishSubject<PostListModel>()
        let nextPostList = PublishSubject<PostListModel>()
        let prefetch = PublishSubject<Void>()
        let networkFail = PublishSubject<Void>()

        
        input.reload
            .map {
                return UserDefaultsManager.userId!
            }
            .flatMap { userId in
                NetworkManager.shared.postCheckUser(userId: userId, productId: ProductIdentifier.market.rawValue, limit: "10", next: "").asObservable()
            }
            .debug("내 상품 조회")
            .subscribe(with: self) { owner, value in
                switch value {
                case .success(let postListModel):
                    result.onNext(postListModel)
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
                print(value)
                guard value.0 >= value.1 - 1 else { return }
                prefetch.onNext(())
            }.disposed(by: disposeBag)
        
        let nextPrefetch = Observable.zip(input.nextCursor, prefetch)
        
        nextPrefetch
            .flatMap { (next, _) in
                NetworkManager.shared.postCheckUser(userId: UserDefaultsManager.userId!, productId: ProductIdentifier.market.rawValue, limit: "10", next: next)
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

        
        return Output(result: result,
                      nextPostList: nextPostList,
                      networkFail: networkFail.asDriver(onErrorJustReturn: ()))
    }
}
