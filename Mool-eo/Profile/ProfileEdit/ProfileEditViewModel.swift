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
        let changeNickname: Observable<Void>
        let beforeIntroduction: String
        let afterIntroduction: Observable<String>
        let changeIntroduction: Observable<Void>
        let beforeProfileImageData: Data?
        let afterProfileImageData: BehaviorSubject<Data?>
    }
    
    struct Output {
        let profileImageEditButtonTap: Driver<Void>
        let nicknameValidation: Driver<Bool>
        let introductionValidation: Driver<Bool>
        let completeButtonValidation: Driver<Bool>
        let profileEditSuccessTrigger: PublishSubject<Void>
        let cancelButtonTap: Observable<Void>
    }
    
    func transform(input: Input) -> Output {
        
        let nicknameValidation = BehaviorSubject(value: true)
        let introductionValidation = BehaviorSubject(value: true)
        let changeValidation = BehaviorSubject(value: true)
        let completeButtonValidation = BehaviorSubject(value: true)
        let profileSuccessTrigger = PublishSubject<Void>()
        
        input.changeNickname
            .withLatestFrom(input.afterNickname)
            .map { value in
                let idRegex = "^[^\\s]{2,10}$"
                let idPredicate = NSPredicate(format: "SELF MATCHES %@", idRegex)
                return idPredicate.evaluate(with: value)
            }
            .debug("nickname")
            .bind(with: self) { owner, value in
                nicknameValidation.onNext(value)
            }.disposed(by: disposeBag)
        
        input.changeIntroduction
            .withLatestFrom(input.afterIntroduction)
            .map { value in
                return value.count < 15
            }
            .debug("introduction")
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
        
        input.completeButtonTap
            .withLatestFrom(profileEditObservable)
            .flatMap { query in
                NetworkManager.profileEdit(query: query)
            }
            .debug()
            .subscribe(with: self) { owenr, value in
                profileSuccessTrigger.onNext(())
            } onError: { owner, error in
                print("오류 발생")
            }.disposed(by: disposeBag)
        
        return Output(profileImageEditButtonTap: input.profileImageEditButtonTap.asDriver(onErrorJustReturn: ()),
                      nicknameValidation: nicknameValidation.asDriver(onErrorJustReturn: false),
                      introductionValidation: introductionValidation.asDriver(onErrorJustReturn: false),
                      completeButtonValidation: completeButtonValidation.asDriver(onErrorJustReturn: false),
                      profileEditSuccessTrigger: profileSuccessTrigger,
                      cancelButtonTap: input.cancelButtonTap)
    }
}
