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
        let name: Observable<String>
        let birthday: Observable<String>
        let profileImage: Observable<String>
        let profileImageEditButtonTap: Observable<Void>
    }
    
    struct Output {
        let name: Driver<String>
        let birthday: Driver<String>
        let profileImage: Driver<String>
        let profileImageEditButtonTap: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        
        return Output(name: input.name.asDriver(onErrorJustReturn: ""),
                      birthday: input.birthday.asDriver(onErrorJustReturn: ""), 
                      profileImage: input.profileImage.asDriver(onErrorJustReturn: ""),
                      profileImageEditButtonTap: input.profileImageEditButtonTap.asDriver(onErrorJustReturn: ()))
    }
}
