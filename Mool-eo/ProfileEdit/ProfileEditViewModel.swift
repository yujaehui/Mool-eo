//
//  ProfileEditViewModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/18/24.
//

import Foundation
import RxSwift
import RxCocoa

final class ProfileEditViewModel: ViewModelType {
    var disposeBag: DisposeBag = DisposeBag()
    
    struct Input {
        let profileImageEditButtonTap: Observable<Void>
        let completeButtonTap: Observable<Void>
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
        let networkFail: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        let nicknameValidation = BehaviorSubject(value: false)
        let changeValidation = BehaviorSubject(value: false)
        let completeButtonValidation = BehaviorSubject(value: false)
        let profileEditSuccessTrigger = PublishSubject<Void>()
        let networkFail = PublishSubject<Void>()

        validateNickname(input: input, nicknameValidation: nicknameValidation)
        validateChange(input: input, changeValidation: changeValidation)
        validateCompleteButton(input: input, nicknameValidation: nicknameValidation, changeValidation: changeValidation, completeButtonValidation: completeButtonValidation)
        handleProfileEdit(input: input, profileEditSuccessTrigger: profileEditSuccessTrigger, networkFail: networkFail)

        return Output(profileImageEditButtonTap: input.profileImageEditButtonTap.asDriver(onErrorJustReturn: ()),
                      nicknameValidation: nicknameValidation.asDriver(onErrorJustReturn: false),
                      completeButtonValidation: completeButtonValidation.asDriver(onErrorJustReturn: false),
                      profileEditSuccessTrigger: profileEditSuccessTrigger.asDriver(onErrorJustReturn: ()),
                      networkFail: networkFail.asDriver(onErrorJustReturn: ()))
    }
    
    private func validateNickname(input: Input, nicknameValidation: BehaviorSubject<Bool>) {
        input.afterNickname
            .map { value in
                let nicknameRegex = "^[^\\s]{2,10}$"
                let nicknamePredicate = NSPredicate(format: "SELF MATCHES %@", nicknameRegex)
                return nicknamePredicate.evaluate(with: value)
            }
            .bind(with: self) { owner, value in
                nicknameValidation.onNext(value)
            }.disposed(by: disposeBag)
    }
    
    private func validateChange(input: Input, changeValidation: BehaviorSubject<Bool>) {
        Observable.combineLatest(input.afterNickname, input.afterProfileImageData)
            .map { $0.0 != input.beforeNickname || $0.1 != input.beforeProfileImageData }
            .bind(with: self) { owner, value in
                changeValidation.onNext(value)
            }.disposed(by: disposeBag)
    }
    
    private func validateCompleteButton(input: Input, nicknameValidation: BehaviorSubject<Bool>, changeValidation: BehaviorSubject<Bool>, completeButtonValidation: BehaviorSubject<Bool>) {
        Observable.combineLatest(nicknameValidation, changeValidation)
            .map { $0.0 && $0.1 }
            .bind(with: self) { owner, value in
                completeButtonValidation.onNext(value)
            }.disposed(by: disposeBag)
    }
    
    private func handleProfileEdit(input: Input, profileEditSuccessTrigger: PublishSubject<Void>, networkFail: PublishSubject<Void>) {
        input.completeButtonTap
            .withLatestFrom(Observable.combineLatest(input.afterNickname, input.afterProfileImageData))
            .map { ProfileEditQuery(nick: $0.0, profile: $0.1 ?? Data()) }
            .flatMap { NetworkManager.shared.profileEdit(query: $0) }
            .subscribe(with: self) { owner, value in
                switch value {
                case .success(_): profileEditSuccessTrigger.onNext(())
                case .error(let error): owner.handleNetworkError(error: error, networkFail: networkFail)
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
