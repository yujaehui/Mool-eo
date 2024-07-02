//
//  UserProfileViewModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 7/1/24.
//

import Foundation
import RxSwift
import RxCocoa

class UserProfileViewModel: ViewModelType {
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
        let notFoundErr: Driver<Void>
        let networkFail: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        let result = PublishSubject<(ProfileModel, PostListModel, PostListModel)>()
        let profileEditButtonTap = PublishSubject<(ProfileModel, Data?)>()
        let productDetail = PublishSubject<PostModel>()
        let postDetail = PublishSubject<PostModel>()
        let moreDetail = PublishSubject<MoreType>()
        let notFoundErr = PublishSubject<Void>()
        let networkFail = PublishSubject<Void>()
        
        input.reload
            .map {
                UserDefaultsManager.userId!
            }
            .flatMap { userId in
                Observable.zip(
                    NetworkManager.shared.profileCheck().asObservable(),
                    NetworkManager.shared.postCheckUser(userId: userId, productId: ProductIdentifier.market.rawValue, limit: "10", next: "").asObservable(),
                    NetworkManager.shared.postCheckUser(userId: userId, productId: ProductIdentifier.postBoard.rawValue, limit: "10", next: "").asObservable()
                ).map { profileResult, productResult, postResult -> (NetworkResult<ProfileModel>, NetworkResult<PostListModel>, NetworkResult<PostListModel>) in
                    return (profileResult, productResult, postResult)
                }
            }
            .debug("유저 프로필 및 포스트 조회")
            .subscribe(with: self) { owner, value in
                switch (value.0, value.1, value.2) {
                case (.success(let profileModel), .success(let productModel), .success(let postModel)):
                    result.onNext((profileModel, productModel, postModel))
                case (.error(let profileError), _, _):
                    switch profileError {
                    case .networkFail: networkFail.onNext(())
                    default: print("⚠️OTHER ERROR : \(profileError)⚠️")
                    }
                case (_, .error(let productError), _):
                    switch productError {
                    case .networkFail: networkFail.onNext(())
                    default: print("⚠️OTHER ERROR : \(productError)⚠️")
                    }
                case (_, _, .error(let postError)):
                    switch postError {
                    case .networkFail: networkFail.onNext(())
                    default: print("⚠️OTHER ERROR : \(postError)⚠️")
                    }
                }
            }.disposed(by: disposeBag)
        
        
        input.profileEditButtonTap
            .flatMap { _ in
                NetworkManager.shared.profileCheck()
            }
            .withLatestFrom(input.profileImageData) { profileModel, profileImageData in
                return (profileModel, profileImageData)
            }
            .debug("프로필 조회")
            .subscribe(with: self) { owner, value in
                switch value.0 {
                case .success(let profileModel):
                    profileEditButtonTap.onNext((profileModel, value.1))
                case .error(let error):
                    print(error)
                }
            }.disposed(by: disposeBag)
        
        Observable.zip(input.modelSelected, input.itemSelected)
            .bind(with: self) { owner, value in
                switch value.0 {
                case .product(let product): productDetail.onNext(product)
                case .post(let post): postDetail.onNext(post)
                case .more(let more): moreDetail.onNext(more)
                default: break
                }
            }.disposed(by: disposeBag)
        
        return Output(result: result,
                      profileEditButtonTap: profileEditButtonTap,
                      productDetail: productDetail,
                      postDetail: postDetail,
                      moreDetail: moreDetail,
                      notFoundErr: notFoundErr.asDriver(onErrorJustReturn: ()),
                      networkFail: networkFail.asDriver(onErrorJustReturn: ()))
    }
}

