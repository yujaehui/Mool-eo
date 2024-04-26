//
//  PostDetailViewModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/20/24.
//

import Foundation
import RxSwift
import RxCocoa

class PostDetailViewModel: ViewModelType {
    var disposeBag: DisposeBag = DisposeBag()
    
    struct Input {
        let keyboardWillShow: Observable<Notification>
        let keyboardWillHide: Observable<Notification>
        let comment: Observable<String>
        let textViewBegin: Observable<Void>
        let textViewEnd: Observable<Void>
        let viewDidLoadTrigger: Observable<String>
    }
    
    struct Output {
        let keyboardWillShow: Observable<Notification>
        let keyboardWillHide: Observable<Notification>
        let text: Driver<String?>
        let textColorType: Driver<Bool>
        let postDetail: PublishSubject<PostModel>
    }
    
    func transform(input: Input) -> Output {
        let placeholderText = "댓글을 입력해주세요"
        let text = BehaviorRelay<String?>(value: placeholderText)
        let textColorType = BehaviorRelay<Bool>(value: false)
        let postDetail = PublishSubject<PostModel>()
        
        input.textViewBegin
            .withLatestFrom(input.comment)
            .bind(with: self) { owner, value in
                if value == text.value {
                    text.accept(nil)
                    textColorType.accept(true)
                }
            }.disposed(by: disposeBag)
        
        input.textViewEnd
            .withLatestFrom(input.comment)
            .bind(with: self) { owner, value in
                if value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    text.accept(placeholderText)
                    textColorType.accept(false)
                }
            }.disposed(by: disposeBag)
        
        
        input.viewDidLoadTrigger
            .flatMap { value in
                NetworkManager.postCheckSpecific(postId: value)
            }
            .debug("postDetail")
            .subscribe(with: self) { owner, value in
                postDetail.onNext(value)
            }.disposed(by: disposeBag)
        
        return Output(keyboardWillShow: input.keyboardWillShow, keyboardWillHide: input.keyboardWillHide, text: text.asDriver(), textColorType: textColorType.asDriver(), postDetail: postDetail)
    }
}
