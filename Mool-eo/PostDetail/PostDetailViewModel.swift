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
        let postID: Observable<String>
        let uploadButtonClicked: Observable<Void>
        let reload: BehaviorSubject<Void>
    }
    
    struct Output {
        let keyboardWillShow: Observable<Notification>
        let keyboardWillHide: Observable<Notification>
        let text: Driver<String?>
        let textColorType: Driver<Bool>
        let postDetail: PublishSubject<PostModel>
        let commentUploadSuccessTrigger: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        let placeholderText = "댓글을 입력해주세요"
        let text = BehaviorRelay<String?>(value: placeholderText)
        let textColorType = BehaviorRelay<Bool>(value: false)
        let postDetail = PublishSubject<PostModel>()
        let commentUploadSuccessTrigger = PublishSubject<Void>()
        
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
        
        
        input.reload
            .withLatestFrom(input.postID)
            .flatMap { value in
                NetworkManager.postCheckSpecific(postId: value)
            }
            .debug("postDetail")
            .subscribe(with: self) { owner, value in
                postDetail.onNext(value)
            }.disposed(by: disposeBag)
        
        let comment = input.comment.map { content in
                return CommentQuery(content: content)
            }
        
        let ObservableComment = Observable.combineLatest(comment, input.postID)
        
        input.uploadButtonClicked
            .withLatestFrom(ObservableComment)
            .flatMap { commentQuery, postID in
                NetworkManager.commentUpload(query: commentQuery, postId: postID)
            }.debug("commnet")
            .subscribe(with: self) { owner, value in
                commentUploadSuccessTrigger.onNext(())
            } onError: { owner, error in
                print("오류 발생")
            }.disposed(by: disposeBag)
        
        
        return Output(keyboardWillShow: input.keyboardWillShow, keyboardWillHide: input.keyboardWillHide, text: text.asDriver(), textColorType: textColorType.asDriver(), postDetail: postDetail, commentUploadSuccessTrigger: commentUploadSuccessTrigger.asDriver(onErrorJustReturn: ()))
    }
}
