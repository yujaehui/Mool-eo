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
        let postId: Observable<String>
        let reload: BehaviorSubject<Void>
        let postEditButtonTap: Observable<Void>
        let postDeleteButtonTap: Observable<Void>
        let likeStatus: PublishSubject<Bool>
        let commentTextViewBegin: Observable<Void>
        let commentTextViewEnd: Observable<Void>
        let comment: Observable<String>
        let commentUploadButtonTap: Observable<Void>
        let itemDeletedWithCommentId: Observable<(IndexPath, String)>
    }
    
    struct Output {
        let postDetail: PublishSubject<PostModel>
        let editPostDetail: PublishSubject<PostModel>
        let postDeleteSuccessTrigger: Driver<Void>
        let likeUploadSuccessTrigger: Driver<Void>
        let commentText: Driver<String?>
        let commentTextColorType: Driver<Bool>
        let commentButtonValidation: Driver<Bool>
        let commentUploadSuccessTrigger: Driver<Void>
        let commentDeleteSuccessTrigger: Driver<IndexPath>
        let networkFail: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        let postDetail = PublishSubject<PostModel>()
        let editPostDetail = PublishSubject<PostModel>()
        let postDeleteSuccessTrigger = PublishSubject<Void>()
        
        let likeUploadSuccessTrigger = PublishSubject<Void>()
        
        let placeholderText = "댓글을 입력해주세요"
        let commentText = BehaviorRelay<String?>(value: placeholderText)
        let commentTextColorType = BehaviorRelay<Bool>(value: false)
        let commentButtonValidation = PublishSubject<Bool>()
        let commentUploadSuccessTrigger = PublishSubject<Void>()
        let commentDeleteSuccessTrigger = PublishSubject<IndexPath>()
        
        let networkFail = PublishSubject<Void>()
        
        // MARK: - 게시글
        // 게시글 조회
        input.reload
            .withLatestFrom(input.postId)
            .flatMap { postId in
                NetworkManager.shared.postCheckSpecific(postId: postId)
            }
            .subscribe(with: self) { owner, value in
                switch value {
                case .success(let postModel): postDetail.onNext(postModel)
                case .error(let error):
                    switch error {
                    case .networkFail: networkFail.onNext(())
                    default: print("⚠️OTHER ERROR : \(error)⚠️")
                    }
                }
            }.disposed(by: disposeBag)
        
        // 게시글 편집
        input.postEditButtonTap
            .withLatestFrom(input.postId)
            .flatMap { postId in
                NetworkManager.shared.postCheckSpecific(postId: postId)
            }
            .subscribe(with: self) { owner, value in
                switch value {
                case .success(let postModel): editPostDetail.onNext(postModel)
                case .error(let error):
                    switch error {
                    case .networkFail: networkFail.onNext(())
                    default: print("⚠️OTHER ERROR : \(error)⚠️")
                    }
                }
            }.disposed(by: disposeBag)
        
        // 게시글 삭제
        input.postDeleteButtonTap
            .withLatestFrom(input.postId)
            .flatMap { postId in
                NetworkManager.shared.postDelete(postId: postId)
            }
            .subscribe(with: self) { owner, value in
                switch value {
                case .success(_): postDeleteSuccessTrigger.onNext(())
                case .error(let error):
                    switch error {
                    case .networkFail: networkFail.onNext(())
                    default: print("⚠️OTHER ERROR : \(error)⚠️")
                    }
                }
            }.disposed(by: disposeBag)
        
        // MARK: - 좋아요
        let likeQuery = input.likeStatus.map { status in
            return LikePostQuery(like_status: status)
        }
        
        let likeObservable = Observable.combineLatest(likeQuery, input.postId)
        
        // 좋아요 업로드
        input.likeStatus
            .withLatestFrom(likeObservable)
            .flatMap { likeQuery, postId in
                NetworkManager.shared.likePostUpload(query: likeQuery, postId: postId)
            }
            .subscribe(with: self) { owner, value in
                switch value {
                case .success(_): likeUploadSuccessTrigger.onNext(())
                case .error(let error):
                    switch error {
                    case .networkFail: networkFail.onNext(())
                    default: print("⚠️OTHER ERROR : \(error)⚠️")
                    }
                }
            }.disposed(by: disposeBag)
        
        // MARK: - 댓글
        // 댓글 입력이 시작되는 시점
        input.commentTextViewBegin
            .withLatestFrom(input.comment)
            .bind(with: self) { owner, value in
                if value == commentText.value {
                    commentText.accept(nil)
                    commentTextColorType.accept(true)
                }
            }.disposed(by: disposeBag)
        
        // 댓글 입력이 종료되는 시점
        input.commentTextViewEnd
            .withLatestFrom(input.comment)
            .bind(with: self) { owner, value in
                if value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    commentText.accept(placeholderText)
                    commentTextColorType.accept(false)
                }
            }.disposed(by: disposeBag)
        
        input.comment
            .bind(with: self) { owner, value in
                commentButtonValidation.onNext(!value.isEmpty)
            }.disposed(by: disposeBag)
        
        let commentQuery = input.comment.map { content in
            return CommentQuery(content: content)
        }
        
        let commentObservable = Observable.combineLatest(commentQuery, input.postId)
        
        // 댓글 업로드
        input.commentUploadButtonTap
            .withLatestFrom(commentObservable)
            .flatMap { commentQuery, postId in
                NetworkManager.shared.commentUpload(query: commentQuery, postId: postId)
            }
            .subscribe(with: self) { owner, value in
                switch value {
                case .success(_): commentUploadSuccessTrigger.onNext(())
                case .error(let error):
                    switch error {
                    case .networkFail: networkFail.onNext(())
                    default: print("⚠️OTHER ERROR : \(error)⚠️")
                    }
                }
            }.disposed(by: disposeBag)
        
        // 댓글 삭제
        input.itemDeletedWithCommentId
            .flatMap { indexPath, commentId in
                input.postId
                    .take(1)
                    .flatMap { postId in
                        NetworkManager.shared.commentDelete(postId: postId, commentId: commentId)
                            .map { result in (indexPath, result) }
                    }
            }
            .subscribe(with: self) { owner, value in
                switch value.1 {
                case .success(_): commentDeleteSuccessTrigger.onNext(value.0)
                case .error(let error):
                    switch error {
                    case .networkFail: networkFail.onNext(())
                    default: print("⚠️OTHER ERROR : \(error)⚠️")
                    }
                }
            }.disposed(by: disposeBag)
        
        return Output(postDetail: postDetail,
                      editPostDetail: editPostDetail,
                      postDeleteSuccessTrigger: postDeleteSuccessTrigger.asDriver(onErrorJustReturn: ()),
                      likeUploadSuccessTrigger: likeUploadSuccessTrigger.asDriver(onErrorJustReturn: ()),
                      commentText: commentText.asDriver(),
                      commentTextColorType: commentTextColorType.asDriver(),
                      commentButtonValidation: commentButtonValidation.asDriver(onErrorJustReturn: false),
                      commentUploadSuccessTrigger: commentUploadSuccessTrigger.asDriver(onErrorJustReturn: ()),
                      commentDeleteSuccessTrigger: commentDeleteSuccessTrigger.asDriver(onErrorJustReturn: IndexPath()),
                      networkFail: networkFail.asDriver(onErrorJustReturn: ()))
    }
}
