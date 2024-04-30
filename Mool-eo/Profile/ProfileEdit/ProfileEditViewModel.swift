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
        let beforeIntroduction: String
        let afterIntroduction: Observable<String>
        let beforeProfileImageData: Data?
        let afterProfileImageData: BehaviorSubject<Data?>
    }
    
    struct Output {
        let profileImageEditButtonTap: Driver<Void>
        let nicknameValidation: Driver<Bool>
        let introductionValidation: Driver<Bool>
        let completeButtonValidation: Driver<Bool>
        let profileEditSuccessTrigger: Driver<Void>
        let cancelButtonTap: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        let nicknameValidation = BehaviorSubject(value: false)
        let introductionValidation = BehaviorSubject(value: false)
        let changeValidation = BehaviorSubject(value: false)
        let completeButtonValidation = BehaviorSubject(value: false)
        let profileSuccessTrigger = PublishSubject<Void>()
        
        input.afterNickname
            .map { value in
                let nicknameRegex = "^[^\\s]{2,10}$"
                let nicknamePredicate = NSPredicate(format: "SELF MATCHES %@", nicknameRegex)
                return nicknamePredicate.evaluate(with: value)
            }
            .bind(with: self) { owner, value in
                nicknameValidation.onNext(value)
            }.disposed(by: disposeBag)
        
        input.afterIntroduction
            .map { value in
                return value.count < 15
            }
            .bind(with: self) { owner, value in
                introductionValidation.onNext(value)
            }.disposed(by: disposeBag)
        
        Observable.combineLatest(input.afterNickname, input.afterIntroduction, input.afterProfileImageData)
            .map { (nick, intro, image) in
                return nick != input.beforeNickname || intro != input.beforeIntroduction || image != input.beforeProfileImageData
            }
            .bind(with: self) { owner, value in
                changeValidation.onNext(value)
            }.disposed(by: disposeBag)
        
        Observable.combineLatest(nicknameValidation, introductionValidation, changeValidation)
            .map { (nickValid, introValid, changeValid) in
                return nickValid && introValid && changeValid
            }
            .bind(with: self) { owner, value in
                completeButtonValidation.onNext(value)
            }.disposed(by: disposeBag)
        
        let profileEditObservable = Observable.combineLatest(input.afterNickname, input.afterIntroduction, input.afterProfileImageData)
            .map { (nick, intro, image) in
                return ProfileEditQuery(nick: nick, birthDay: intro, profile: image ?? Data())
            }
        
        // 프로필 수정 네트워크 통신
        input.completeButtonTap
            .withLatestFrom(profileEditObservable)
            .flatMap { query in
                NetworkManager.profileEdit(query: query)
            }
            .debug("프로필 수정")
            .subscribe(with: self) { owenr, value in
                profileSuccessTrigger.onNext(())
            } onError: { owner, error in
                print("오류 발생")
            }.disposed(by: disposeBag)
        
        return Output(profileImageEditButtonTap: input.profileImageEditButtonTap.asDriver(onErrorJustReturn: ()),
                      nicknameValidation: nicknameValidation.asDriver(onErrorJustReturn: false),
                      introductionValidation: introductionValidation.asDriver(onErrorJustReturn: false),
                      completeButtonValidation: completeButtonValidation.asDriver(onErrorJustReturn: false),
                      profileEditSuccessTrigger: profileSuccessTrigger.asDriver(onErrorJustReturn: ()),
                      cancelButtonTap: input.cancelButtonTap.asDriver(onErrorJustReturn: ()))
    }
}
