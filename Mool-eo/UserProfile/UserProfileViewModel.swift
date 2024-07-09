//
//  UserProfileViewModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 7/1/24.
//

import Foundation
import RxSwift
import RxCocoa

final class UserProfileViewModel: ViewModelType {
    var disposeBag: DisposeBag = DisposeBag()
    
    struct Input {
        let reload: BehaviorSubject<Void>
        let profileImageData: PublishSubject<Data?>
        let profileEditButtonTap: PublishSubject<Void>
        let modelSelected: Observable<UserProfileSectionItem>
        let itemSelected: Observable<IndexPath>
    }
    
    struct Output {
        let result: PublishSubject<(ProfileModel, PostListModel, PostListModel)>
        let profileEditButtonTap: PublishSubject<(ProfileModel, Data?)>
        let productDetail: PublishSubject<PostModel>
        let postDetail: PublishSubject<PostModel>
        let moreDetail: PublishSubject<MoreType>
        let networkFail: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        let result = PublishSubject<(ProfileModel, PostListModel, PostListModel)>()
        let profileEditButtonTap = PublishSubject<(ProfileModel, Data?)>()
        let productDetail = PublishSubject<PostModel>()
        let postDetail = PublishSubject<PostModel>()
        let moreDetail = PublishSubject<MoreType>()
        let networkFail = PublishSubject<Void>()
    
        handleReload(input: input, result: result, networkFail: networkFail)
        handleProfileEdit(input: input, profileEditButtonTap: profileEditButtonTap, networkFail: networkFail)
        handleDetail(input: input, productDetail: productDetail, postDetail: postDetail, moreDetail: moreDetail)

        return Output(result: result,
                      profileEditButtonTap: profileEditButtonTap,
                      productDetail: productDetail,
                      postDetail: postDetail,
                      moreDetail: moreDetail,
                      networkFail: networkFail.asDriver(onErrorJustReturn: ()))
    }
    
    private func handleReload(input: Input, result: PublishSubject<(ProfileModel, PostListModel, PostListModel)>, networkFail: PublishSubject<Void>) {
        input.reload
            .map { UserDefaultsManager.userId! }
            .flatMap { userId in
                Observable.zip(
                    NetworkManager.shared.profileCheck().asObservable(),
                    NetworkManager.shared.postCheckUser(userId: userId, productId: ProductIdentifier.product.rawValue, limit: "10", next: "").asObservable(),
                    NetworkManager.shared.postCheckUser(userId: userId, productId: ProductIdentifier.post.rawValue, limit: "10", next: "").asObservable()
                ).map { profileResult, productResult, postResult -> (NetworkResult<ProfileModel>, NetworkResult<PostListModel>, NetworkResult<PostListModel>) in
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
    
    private func handleProfileEdit(input: Input, profileEditButtonTap: PublishSubject<(ProfileModel, Data?)>, networkFail: PublishSubject<Void>) {
        input.profileEditButtonTap
            .flatMap { NetworkManager.shared.profileCheck() }
            .withLatestFrom(input.profileImageData) { profileModel, profileImageData in
                return (profileModel, profileImageData)
            }
            .subscribe(with: self) { owner, value in
                switch value.0 {
                case .success(let profileModel): profileEditButtonTap.onNext((profileModel, value.1))
                case .error(let error): owner.handleNetworkError(error: error, networkFail: networkFail)
                }
            }
            .disposed(by: disposeBag)
    }
    
    private func handleDetail(input: Input, productDetail: PublishSubject<PostModel>, postDetail: PublishSubject<PostModel>, moreDetail: PublishSubject<MoreType>) {
        Observable.zip(input.modelSelected, input.itemSelected)
            .bind(with: self) { owner, value in
                switch value.0 {
                case .product(let product): productDetail.onNext(product)
                case .post(let post): postDetail.onNext(post)
                case .more(let more): moreDetail.onNext(more)
                default: break
                }
            }.disposed(by: disposeBag)
    }
    
    private func handleNetworkError(error: NetworkError, networkFail: PublishSubject<Void>) {
        switch error {
        case .networkFail: networkFail.onNext(())
        default: print("⚠️OTHER ERROR : \(error)⚠️")
        }
    }
}

