//
//  OtherUserProfileViewModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/2/24.
//

import Foundation
import RxSwift
import RxCocoa

final class OtherUserProfileViewModel: ViewModelType {
    var disposeBag: DisposeBag = DisposeBag()
    
    struct Input {
        let reload: BehaviorSubject<Void>
        let modelSelected: Observable<OtherUserProfileSectionItem>
        let itemSelected: Observable<IndexPath>
        let userId: String
        let followStatus: PublishSubject<Bool>
    }
    
    struct Output {
        let result: PublishSubject<(OtherUserProfileModel, PostListModel, PostListModel)>
        let productDetail: PublishSubject<PostModel>
        let postDetail: PublishSubject<PostModel>
        let followOrUnfollowSuccessTrigger: Driver<Void>
        let networkFail: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        let result = PublishSubject<(OtherUserProfileModel, PostListModel, PostListModel)>()
        let productDetail = PublishSubject<PostModel>()
        let postDetail = PublishSubject<PostModel>()
        let followOrUnfollowSuccessTrigger = PublishSubject<Void>()
        let networkFail = PublishSubject<Void>()

        handleReload(input: input, result: result, networkFail: networkFail)
        handleDetail(input: input, productDetail: productDetail, postDetail: postDetail)
        followOrUnfollow(input: input, followOrUnfollowSuccessTrigger: followOrUnfollowSuccessTrigger, networkFail: networkFail)
        
        return Output(result: result,
                      productDetail: productDetail,
                      postDetail: postDetail,
                      followOrUnfollowSuccessTrigger: followOrUnfollowSuccessTrigger.asDriver(onErrorJustReturn: ()),
                      networkFail: networkFail.asDriver(onErrorJustReturn: ()))
    }
    
    private func handleReload(input: Input, result: PublishSubject<(OtherUserProfileModel, PostListModel, PostListModel)>, networkFail: PublishSubject<Void>) {
        input.reload
            .map { input.userId }
            .flatMap { userId in
                Observable.zip(
                    NetworkManager.shared.otherUserProfileCheck(userId: userId).asObservable(),
                    NetworkManager.shared.postCheckUser(userId: userId, productId: ProductIdentifier.product.rawValue, limit: "10", next: "").asObservable(),
                    NetworkManager.shared.postCheckUser(userId: userId, productId: ProductIdentifier.post.rawValue, limit: "10", next: "").asObservable()
                ).map { profileResult, productResult, postResult -> (NetworkResult<OtherUserProfileModel>, NetworkResult<PostListModel>, NetworkResult<PostListModel>) in
                    return (profileResult, productResult, postResult)
                }
            }
            .subscribe(with: self) { owner, value in
                switch (value.0, value.1, value.2) {
                case (.success(let profileModel), .success(let productModel), .success(let postModel)): result.onNext((profileModel, productModel, postModel))
                case (.error(let profileError), _, _): owner.handleNetworkError(error: profileError, networkFail: networkFail)
                case (_, .error(let productError), _): owner.handleNetworkError(error: productError, networkFail: networkFail)
                case (_, _, .error(let postError)): owner.handleNetworkError(error: postError, networkFail: networkFail)
                }
            }
            .disposed(by: disposeBag)
    }
    
    private func handleDetail(input: Input, productDetail: PublishSubject<PostModel>, postDetail: PublishSubject<PostModel>) {
        Observable.zip(input.modelSelected, input.itemSelected)
            .bind(with: self) { owner, value in
                switch value.0 {
                case .product(let product): productDetail.onNext(product)
                case .post(let post): postDetail.onNext(post)
                default: break
                }
            }
            .disposed(by: disposeBag)
    }

    private func followOrUnfollow(input: Input, followOrUnfollowSuccessTrigger: PublishSubject<Void>, networkFail: PublishSubject<Void>) {
        input.followStatus
            .flatMap { status in
                status ? NetworkManager.shared.unfollow(userId: input.userId) : NetworkManager.shared.follow(userId: input.userId)
            }
            .subscribe(with: self) { owner, value in
                switch value {
                case .success(_): followOrUnfollowSuccessTrigger.onNext(())
                case .error(let error): owner.handleNetworkError(error: error, networkFail: networkFail)
                }
            }
            .disposed(by: disposeBag)
    }

    private func handleNetworkError(error: NetworkError, networkFail: PublishSubject<Void>) {
        switch error {
        case .networkFail: networkFail.onNext(())
        default: print("⚠️OTHER ERROR : \(error)⚠️")
        }
    }
}
