//
//  ProductDetailViewModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/10/24.
//

import Foundation
import RxSwift
import RxCocoa

final class ProductDetailViewModel: ViewModelType {
    
    var disposeBag: DisposeBag = DisposeBag()
    
    struct Input {
        let postId: String
        let reload: BehaviorSubject<Void>
        let likeButtonTap: Observable<Void>
        let buyButtonTap: Observable<Void>
        let deleteButtonTap: PublishSubject<Void>
    }
    
    struct Output {
        let productDetail: PublishSubject<PostModel>
        let networkFail: Driver<Void>
        let likeButtonTapResult: PublishSubject<Void>
        let buyButtonTapResult: PublishSubject<PostModel>
        let deleteButtonTapResult: PublishSubject<Void>
    }
    
    func transform(input: Input) -> Output {
        let productDetail = PublishSubject<PostModel>()
        let networkFail = PublishSubject<Void>()
        let likeButtonTapResult = PublishSubject<Void>()
        let buyButtonTapResult = PublishSubject<PostModel>()
        let deleteButtonTapResult = PublishSubject<Void>()
        
        input.reload
            .flatMap { value in
                NetworkManager.shared.postCheckSpecific(postId: input.postId)
            }
            .subscribe(with: self) { owner, value in
                switch value {
                case .success(let postModel):
                    productDetail.onNext(postModel)
                case .error(let error):
                    switch error {
                    case .networkFail: networkFail.onNext(())
                    default: print("⚠️OTHER ERROR : \(error)⚠️")
                    }
                }
            }.disposed(by: disposeBag)
        
        input.likeButtonTap
            .withLatestFrom(productDetail)
            .map { postModel in
                let userId = UserDefaultsManager.userId!
                let status = !postModel.likesProduct.contains(userId)
                return status
            }
            .map { status in
                
                return LikeProductQuery(like_status: status)
            }
            .flatMap { query in
                NetworkManager.shared.likeProductUpload(query: query, postId: input.postId)
            }
            .subscribe(with: self) { owner, value in
                switch value {
                case .success(_):
                    likeButtonTapResult.onNext(())
                case .error(let error):
                    switch error {
                    case .networkFail: networkFail.onNext(())
                    default: print("⚠️OTHER ERROR : \(error)⚠️")
                    }
                }
            }.disposed(by: disposeBag)
        
        input.buyButtonTap
            .withLatestFrom(productDetail)
            .bind(with: self) { owner, postModel in
                buyButtonTapResult.onNext(postModel)
            }.disposed(by: disposeBag)
        
        input.deleteButtonTap
            .flatMap { postId in
                NetworkManager.shared.postDelete(postId: input.postId)
            }
            .subscribe(with: self) { owner, value in
                switch value {
                case .success(_): deleteButtonTapResult.onNext(())
                case .error(let error):
                    switch error {
                    case .networkFail: networkFail.onNext(())
                    default: print("⚠️OTHER ERROR : \(error)⚠️")
                    }
                }
            }.disposed(by: disposeBag)
        
        
        return Output(productDetail: productDetail, 
                      networkFail: networkFail.asDriver(onErrorJustReturn: ()),
                      likeButtonTapResult: likeButtonTapResult,
                      buyButtonTapResult: buyButtonTapResult,
                      deleteButtonTapResult: deleteButtonTapResult)
    }
}
