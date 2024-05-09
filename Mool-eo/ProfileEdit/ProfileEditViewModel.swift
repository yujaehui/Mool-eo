//
//  ProfileEditViewModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/18/24.
//

import Foundation
import RxSwift
import RxCocoa

class ProfileEditViewModel: ViewModelType {
    var disposeBag: DisposeBag = DisposeBag()
    
    struct Input {
        let profileImageEditButtonTap: Observable<Void>
        let completeButtonTap: Observable<Void>
        let cancelButtonTap: Observable<Void>
        let beforeNickname: String
        let afterNickname: Observable<String>
        let beforeProfileImageData: Data?
        let afterProfileImageData: BehaviorSubject<Data?>
    }
    
    struct Output {
        let profileImageEditButtonTap: Driver<Void>
        let nicknameValidation: Driver<Bool>
        let completeButtonValidation: Driver<Bool>
        let profileEditSuccessTrigger: Driver<Void>
        let cancelButtonTap: Driver<Void>
        let networkFail: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        let nicknameValidation = BehaviorSubject(value: false)
        let changeValidation = BehaviorSubject(value: false)
        let completeButtonValidation = BehaviorSubject(value: false)
        let profileSuccessTrigger = PublishSubject<Void>()
        let networkFail = PublishSubject<Void>()
        
        input.afterNickname
            .map { value in
                let nicknameRegex = "^[^\\s]{2,10}$"
                let nicknamePredicate = NSPredicate(format: "SELF MATCHES %@", nicknameRegex)
                return nicknamePredicate.evaluate(with: value)
            }
            .bind(with: self) { owner, value in
                nicknameValidation.onNext(value)
            }.disposed(by: disposeBag)
        
        Observable.combineLatest(input.afterNickname, input.afterProfileImageData)
            .map { (nick, image) in
                return nick != input.beforeNickname || image != input.beforeProfileImageData
            }
            .bind(with: self) { owner, value in
                changeValidation.onNext(value)
            }.disposed(by: disposeBag)
        
        Observable.combineLatest(nicknameValidation, changeValidation)
            .map { (nickValid, changeValid) in
                return nickValid && changeValid
            }
            .bind(with: self) { owner, value in
                completeButtonValidation.onNext(value)
            }.disposed(by: disposeBag)
        
        let profileEditObservable = Observable.combineLatest(input.afterNickname, input.afterProfileImageData)
            .map { (nick, image) in
                return ProfileEditQuery(nick: nick, profile: image ?? Data())
            }
        
        // 프로필 수정 네트워크 통신
        input.completeButtonTap
            .withLatestFrom(profileEditObservable)
            .flatMap { query in
                NetworkManager.shared.profileEdit(query: query)
            }
            .debug("프로필 수정")
            .subscribe(with: self) { owenr, value in
                switch value {
                case .success(_): profileSuccessTrigger.onNext(())
                case .error(let error):
                    switch error {
                    case .networkFail: networkFail.onNext(())
                    default: print("⚠️OTHER ERROR : \(error)⚠️")
                    }
                }
            }.disposed(by: disposeBag)
        
        return Output(profileImageEditButtonTap: input.profileImageEditButtonTap.asDriver(onErrorJustReturn: ()),
                      nicknameValidation: nicknameValidation.asDriver(onErrorJustReturn: false),
                      completeButtonValidation: completeButtonValidation.asDriver(onErrorJustReturn: false),
                      profileEditSuccessTrigger: profileSuccessTrigger.asDriver(onErrorJustReturn: ()),
                      cancelButtonTap: input.cancelButtonTap.asDriver(onErrorJustReturn: ()),
                      networkFail: networkFail.asDriver(onErrorJustReturn: ()))
    }
}
