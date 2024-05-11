//
//  ProductPostDetailViewModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/10/24.
//

import Foundation
import RxSwift
import RxCocoa

class ProductPostDetailViewModel: ViewModelType {
    
    var disposeBag: DisposeBag = DisposeBag()
    
    struct Input {
        let postId: Observable<String>
        let reload: BehaviorSubject<Void>
        let likeButtonTap: Observable<Void>
        let buyButtonTap: Observable<Void>
        let postModel: PublishSubject<PostModel>
    }
    
    struct Output {
        let postDetail: PublishSubject<PostModel>
        let networkFail: Driver<Void>
        let likeButtonTapResult: PublishSubject<Void>
        let buyButtonTapResult: PublishSubject<PostModel>
    }
    
    func transform(input: Input) -> Output {
        let postDetail = PublishSubject<PostModel>()
        let networkFail = PublishSubject<Void>()
        let likeButtonTapResult = PublishSubject<Void>()
        let buyButtonTapResult = PublishSubject<PostModel>()
        
        input.reload
            .withLatestFrom(input.postId)
            .flatMap { value in
                NetworkManager.shared.postCheckSpecific(postId: value)
            }
            .debug("특정 게시글 조회")
            .subscribe(with: self) { owner, value in
                switch value {
                case .success(let postModel):
                    // 특정 게시글 조회
                    postDetail.onNext(postModel)
                case .error(let error):
                    switch error {
                    case .networkFail: networkFail.onNext(())
                    default: print("⚠️OTHER ERROR : \(error)⚠️")
                    }
                }
            }.disposed(by: disposeBag)
        
        input.likeButtonTap
            .withLatestFrom(input.postModel)
            .map { postModel in
                let userId = UserDefaultsManager.userId!
                let status = !postModel.scraps.contains(userId)
                return status
            }
            .map { status in
                return ScrapQuery(like_status: status)
            }
            .withLatestFrom(input.postId) { query, postId in
                return (query, postId)
            }
            .flatMap { (query, postId) in
                NetworkManager.shared.scrapUpload(query: query, postId: postId)
            }
            .debug("스크랩 업로드")
            .subscribe(with: self) { owner, value in
                switch value {
                case .success(let success):
                    likeButtonTapResult.onNext(())
                case .error(let error):
                    switch error {
                    case .networkFail: networkFail.onNext(())
                    default: print("⚠️OTHER ERROR : \(error)⚠️")
                    }
                }
            }.disposed(by: disposeBag)
        
        input.buyButtonTap
            .withLatestFrom(input.postModel)
            .bind(with: self) { owner, postModel in
                buyButtonTapResult.onNext(postModel)
            }.disposed(by: disposeBag)
        
        
        return Output(postDetail: postDetail, 
                      networkFail: networkFail.asDriver(onErrorJustReturn: ()),
                      likeButtonTapResult: likeButtonTapResult,
                      buyButtonTapResult: buyButtonTapResult)
    }
}
