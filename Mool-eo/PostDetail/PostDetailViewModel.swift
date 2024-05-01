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
        let textViewBegin: Observable<Void>
        let textViewEnd: Observable<Void>
        let postId: Observable<String>
        let comment: Observable<String>
        let commentUploadButtonTap: Observable<Void>
        let reload: BehaviorSubject<Void>
        let likeStatus: PublishSubject<Bool>
    }
    
    struct Output {
        let keyboardWillShow: Observable<Notification>
        let keyboardWillHide: Observable<Notification>
        let text: Driver<String?>
        let textColorType: Driver<Bool>
        let postDetail: PublishSubject<PostModel>
        let commentUploadSuccessTrigger: Driver<Void>
        let likeUploadSuccessTrigger: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        let placeholderText = "댓글을 입력해주세요"
        let text = BehaviorRelay<String?>(value: placeholderText)
        let textColorType = BehaviorRelay<Bool>(value: false)
        let postDetail = PublishSubject<PostModel>()
        let commentUploadSuccessTrigger = PublishSubject<Void>()
        let likeUploadSuccessTrigger = PublishSubject<Void>()
        
        // 텍스트뷰 입력이 시작되는 시점
        input.textViewBegin
            .withLatestFrom(input.comment)
            .bind(with: self) { owner, value in
                if value == text.value {
                    text.accept(nil)
                    textColorType.accept(true)
                }
            }.disposed(by: disposeBag)
        
        // 텍스트뷰 입력이 종료되는 시점
        input.textViewEnd
            .withLatestFrom(input.comment)
            .bind(with: self) { owner, value in
                if value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    text.accept(placeholderText)
                    textColorType.accept(false)
                }
            }.disposed(by: disposeBag)
        
        // 특정 게시글 조회 네트워크 통신 진행
        input.reload
            .withLatestFrom(input.postId)
            .flatMap { value in
                NetworkManager.shared.postCheckSpecific(postId: value)
            }
            .debug("특정 게시글 조회")
            .subscribe(with: self) { owner, value in
                postDetail.onNext(value)
            } onError: { owner, error in
                print("오류 발생")
            }.disposed(by: disposeBag)
        
        let commentQuery = input.comment.map { content in
            return CommentQuery(content: content)
        }

        let commentObservable = Observable.combineLatest(commentQuery, input.postId)
        
        // 댓글 업로드 네트워크 통신 진행
        input.commentUploadButtonTap
            .withLatestFrom(commentObservable)
            .flatMap { commentQuery, postId in
                NetworkManager.shared.commentUpload(query: commentQuery, postId: postId)
            }.debug("댓글")
            .subscribe(with: self) { owner, value in
                commentUploadSuccessTrigger.onNext(())
            } onError: { owner, error in
                print("오류 발생")
            }.disposed(by: disposeBag)
        
        let likeQuery = input.likeStatus.map { status in
            return LikeQuery(like_status: status)
        }
        
        let likeObservable = Observable.combineLatest(likeQuery, input.postId)
        
        // 좋아요 업로드 네트워크 통신 진행
        input.likeStatus
            .withLatestFrom(likeObservable)
            .flatMap { likeQuery, postId in
                NetworkManager.shared.likeUpload(query: likeQuery, postId: postId)
            }
            .debug("좋아요 업로드")
            .subscribe(with: self) { owner, value in
                likeUploadSuccessTrigger.onNext(())
            } onError: { owner, error in
                print("오류 발생")
            }.disposed(by: disposeBag)
        
        return Output(keyboardWillShow: input.keyboardWillShow,
                      keyboardWillHide: input.keyboardWillHide,
                      text: text.asDriver(),
                      textColorType: textColorType.asDriver(),
                      postDetail: postDetail,
                      commentUploadSuccessTrigger: commentUploadSuccessTrigger.asDriver(onErrorJustReturn: ()),
                      likeUploadSuccessTrigger: likeUploadSuccessTrigger.asDriver(onErrorJustReturn: ()))
    }
}
