//
//  ProfileViewModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/17/24.
//

import Foundation
import RxSwift
import RxCocoa

class ProfileViewModel: ViewModelType {
    var disposeBag: DisposeBag = DisposeBag()
    
    struct Input {
        let viewDidLoad: Observable<Void>
        let modelSelected: Observable<ProfileSectionItem>
        let itemSelected: Observable<IndexPath>
    }
    
    struct Output {
        let result: PublishSubject<(ProfileModel, PostListModel)>
        let post: Driver<String>
    }
    
    func transform(input: Input) -> Output {
        let result = PublishSubject<(ProfileModel, PostListModel)>()
        let post = PublishSubject<String>()
        
        input.viewDidLoad
            .flatMap { _ in
                Observable.zip(NetworkManager.shared.profileCheck().asObservable(), NetworkManager.shared.postCheckUser().asObservable())
            }
            .debug("프로필 및 유저 포스트 조회")
            .subscribe(with: self) { owner, value in
                result.onNext(value)
            } onError: { owner, error in
                print("오류 발생")
            }
            .disposed(by: disposeBag)   
        
        Observable.zip(input.modelSelected, input.itemSelected)
            .bind(with: self) { owner, value in
                switch value.0 {
                case .myPostItem(let myPost): post.onNext(myPost.postID)
                case .infoItem( _): break
                }
            }.disposed(by: disposeBag)
        
        return Output(result: result, post: post.asDriver(onErrorJustReturn: ""))
    }
}
