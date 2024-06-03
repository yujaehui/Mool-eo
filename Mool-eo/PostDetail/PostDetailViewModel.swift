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
        let didScroll: Observable<Void>
        let textViewBegin: Observable<Void>
        let textViewEnd: Observable<Void>
        let postId: Observable<String>
        let userId: String
        let reload: BehaviorSubject<Void>
        let comment: Observable<String>
        let commentUploadButtonTap: Observable<Void>
        let likeStatus: PublishSubject<Bool>
        let postEditButtonTap: Observable<Void>
        let postDeleteButtonTap: Observable<Void>
        let itemDeletedWithCommentId: Observable<(IndexPath, String)>
    }
    
    struct Output {
        let didScroll: Observable<Void>
        let text: Driver<String?>
        let textColorType: Driver<Bool>
        let postDetail: PublishSubject<PostModel>
        let editPostDetail: PublishSubject<PostModel>
        let commentButtonValidation: Driver<Bool>
        let commentUploadSuccessTrigger: Driver<Void>
        let likeUploadSuccessTrigger: Driver<Void>
        let postDeleteSuccessTrigger: Driver<Void>
        let commentDeleteSuccessTrigger: Driver<IndexPath>
        let networkFail: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        let placeholderText = "댓글을 입력해주세요"
        let text = BehaviorRelay<String?>(value: placeholderText)
        let textColorType = BehaviorRelay<Bool>(value: false)
        let postDetail = PublishSubject<PostModel>()
        let editPostDetail = PublishSubject<PostModel>()
        let commentButtonValidation = PublishSubject<Bool>()
        let commentUploadSuccessTrigger = PublishSubject<Void>()
        let likeUploadSuccessTrigger = PublishSubject<Void>()
        let postDeleteSuccessTrigger = PublishSubject<Void>()
        let commentDeleteSuccessTrigger = PublishSubject<IndexPath>()
        let networkFail = PublishSubject<Void>()
        
        
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
        
        input.comment
            .bind(with: self) { owner, value in
                commentButtonValidation.onNext(!value.isEmpty)
            }.disposed(by: disposeBag)
        
        // MARK: - 특정 게시글 조회 네트워크 통신 진행
        input.reload
            .withLatestFrom(input.postId)
            .flatMap { value in
                NetworkManager.shared.postCheckSpecific(postId: value)
            }
            .debug("특정 게시글 조회")
            .subscribe(with: self) { owner, value in
                switch value {
                case .success(let postModel):
                    postDetail.onNext(postModel)
                case .error(let error):
                    switch error {
                    case .networkFail: networkFail.onNext(())
                    default: print("⚠️OTHER ERROR : \(error)⚠️")
                    }
                }
            }.disposed(by: disposeBag)
        
        // MARK: - 댓글 업로드 네트워크 통신 진행
        let commentQuery = input.comment.map { content in
            return CommentQuery(content: content)
        }
        
        let commentObservable = Observable.combineLatest(commentQuery, input.postId)
        
        input.commentUploadButtonTap
            .withLatestFrom(commentObservable)
            .flatMap { commentQuery, postId in
                NetworkManager.shared.commentUpload(query: commentQuery, postId: postId)
            }
            .debug("댓글")
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
        
        // MARK: - 좋아요 업로드 네트워크 통신 진행
        let likeQuery = input.likeStatus.map { status in
            return LikePostQuery(like_status: status)
        }
        
        let likeObservable = Observable.combineLatest(likeQuery, input.postId)
        
        input.likeStatus
            .withLatestFrom(likeObservable)
            .flatMap { likeQuery, postId in
                NetworkManager.shared.likePostUpload(query: likeQuery, postId: postId)
            }
            .debug("좋아요 업로드")
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
        
        //MARK: - 특정 게시물 삭제 네트워크 통신 진행
        input.postDeleteButtonTap
            .withLatestFrom(input.postId)
            .flatMap { postId in
                NetworkManager.shared.postDelete(postId: postId)
            }
            .debug("특정 게시물 삭제")
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
        
        //MARK: - 댓글 삭제 네트워크 통신 진행
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
        
        input.postEditButtonTap
            .withLatestFrom(input.postId)
            .flatMap { value in
                NetworkManager.shared.postCheckSpecific(postId: value)
            }
            .debug("특정 게시글 조회")
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
        
        return Output(didScroll: input.didScroll,
                      text: text.asDriver(),
                      textColorType: textColorType.asDriver(),
                      postDetail: postDetail,
                      editPostDetail: editPostDetail,
                      commentButtonValidation: commentButtonValidation.asDriver(onErrorJustReturn: false),
                      commentUploadSuccessTrigger: commentUploadSuccessTrigger.asDriver(onErrorJustReturn: ()),
                      likeUploadSuccessTrigger: likeUploadSuccessTrigger.asDriver(onErrorJustReturn: ()),
                      postDeleteSuccessTrigger: postDeleteSuccessTrigger.asDriver(onErrorJustReturn: ()),
                      commentDeleteSuccessTrigger: commentDeleteSuccessTrigger.asDriver(onErrorJustReturn: IndexPath()),
                      networkFail: networkFail.asDriver(onErrorJustReturn: ()))
    }
}
