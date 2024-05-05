//
//  WritePostViewModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/10/24.
//

import Foundation
import RxSwift
import RxCocoa

class WritePostViewModel: ViewModelType {
    
    var disposeBag: DisposeBag = DisposeBag()
    
    struct Input {
        let textViewBegin: Observable<Void>
        let textViewEnd: Observable<Void>
        let postBoard: PostBoardType
        let title: Observable<String>
        let content: Observable<String>
        let selectedImageDataSubject: BehaviorSubject<[Data]>
        let imageSelectedSubject: BehaviorSubject<Bool>
        let imageAddButtonTap: Observable<Void>
        let completeButtonTap: Observable<Void>
        let cancelButtonTap: Observable<Void>
        let type: PostInteractionType
        let postId: Observable<String>
    }
    
    struct Output {
        let text: Driver<String?>
        let textColorType: Driver<Bool>
        let imageAddButtonTap: Driver<Void>
        let completeButtonValidation: Driver<Bool>
        let uploadSuccessTrigger: Driver<Void>
        let editSuccessTrigger: Driver<Void>
        let cancelButtonTap: Driver<Void>
        let forbidden: Driver<Void>
        let badRequest: Driver<Void>
        let notFoundErr: Driver<Void>
        let unauthorized: Driver<Void>
        let networkFail: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        let placeholderText = "내용을 입력해주세요"
        let text = PublishRelay<String?>()
        let textColorType = PublishRelay<Bool>()
        let completeButtonValidation = BehaviorSubject(value: false)
        let uploadSuccessTrigger = PublishSubject<Void>()
        let editSuccessTrigger = PublishSubject<Void>()
        let forbidden = PublishSubject<Void>()
        let badRequest = PublishSubject<Void>()
        let notFoundErr = PublishSubject<Void>()
        let unauthorized = PublishSubject<Void>()
        let networkFail = PublishSubject<Void>()
        
        input.textViewBegin
            .withLatestFrom(input.content)
            .bind(with: self) { owner, value in
                if value == placeholderText {
                    text.accept(nil)
                    textColorType.accept(true)
                }
            }.disposed(by: disposeBag)
        
        input.textViewEnd
            .withLatestFrom(input.content)
            .bind(with: self) { owner, value in
                if value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    text.accept(placeholderText)
                    textColorType.accept(false)
                }
            }.disposed(by: disposeBag)
        
        Observable.combineLatest(input.title, input.content)
            .map { (title, content) in
                return title != "" && content != "" && content != placeholderText
            }
            .bind(with: self) { owner, value in
                completeButtonValidation.onNext(value)
            }.disposed(by: disposeBag)
        
        
        let filesQuery = input.selectedImageDataSubject.map { files in
            return FilesQuery(files: files)
        }
        
        let postQuery = Observable.combineLatest(input.title, input.content).map { (title, content) in
            return PostQuery(title: title, content: content, product_id: input.postBoard.rawValue, files: nil)
        }
        
        let editPostObservable = Observable.combineLatest(postQuery, input.postId)
        
        switch input.type {
        case .upload:
            input.completeButtonTap
                .withLatestFrom(input.imageSelectedSubject)
                .flatMap { imageSelected -> Observable<PostQuery> in
                    if imageSelected {
                        return filesQuery
                            .flatMapLatest { filesQuery in
                                NetworkManager.shared.imageUpload(query: filesQuery)
                            }
                            .flatMapLatest { result -> Observable<PostQuery> in
                                switch result {
                                case .success(let filesModel):
                                    let postQuery = Observable.combineLatest(input.title, input.content).map { (title, content) in
                                        return PostQuery(title: title, content: content, product_id: input.postBoard.rawValue, files: filesModel.files)
                                    }
                                    return postQuery
                                case .error(let error):
                                    switch error {
                                    case .forbidden: forbidden.onNext(())
                                    case .badRequest: badRequest.onNext(())
                                    default: print("⚠️OTHER ERROR : \(error)⚠️")
                                    }
                                    
                                    let postQuery = Observable.combineLatest(input.title, input.content).map { (title, content) in
                                        return PostQuery(title: title, content: content, product_id: input.postBoard.rawValue, files: nil)
                                    }
                                    return postQuery
                                }
                            }
                    } else {
                        let postQuery = Observable.combineLatest(input.title, input.content).map { (title, content) in
                            return PostQuery(title: title, content: content, product_id: input.postBoard.rawValue, files: nil)
                        }
                        return postQuery
                    }
                }
                .flatMap { query in
                    NetworkManager.shared.postUpload(query: query)
                }
                .debug("게시글 업로드")
                .do(onSubscribe: { networkFail.onNext(()) })
                .retry(3)
                .share()
                .subscribe(with: self) { owner, value in
                    switch value {
                    case .success(_): uploadSuccessTrigger.onNext(())
                    case .error(let error):
                        switch error {
                        case .notFoundErr: notFoundErr.onNext(())
                        case .forbidden: forbidden.onNext(())
                        default: print("⚠️OTHER ERROR : \(error)⚠️")
                        }
                    }
                } onError: { owner, error in
                    print("🛰️NETWORK ERROR : \(error)🛰️")
                    networkFail.onNext(())
                }.disposed(by: disposeBag)
            
        case .edit:
            input.completeButtonTap
                .withLatestFrom(editPostObservable)
                .flatMap { query, postId in
                    NetworkManager.shared.postEdit(query: query, postId: postId)
                }
                .debug("게시글 수정")
                .do(onSubscribe: { networkFail.onNext(()) })
                .retry(3)
                .share()
                .subscribe(with: self) { owner, value in
                    switch value {
                    case .success(_): editSuccessTrigger.onNext(())
                    case .error(let error):
                        switch error {
                        case .unauthorized: unauthorized.onNext(())
                        case .notFoundErr: notFoundErr.onNext(())
                        case .forbidden: forbidden.onNext(())
                        default: print("⚠️OTHER ERROR : \(error)⚠️")
                        }
                    }
                } onError: { owner, error in
                    print("🛰️NETWORK ERROR : \(error)🛰️")
                    networkFail.onNext(())
                }.disposed(by: disposeBag)
        }
        
        return Output(text: text.asDriver(onErrorJustReturn: ""),
                      textColorType: textColorType.asDriver(onErrorJustReturn: false),
                      imageAddButtonTap: input.imageAddButtonTap.asDriver(onErrorJustReturn: ()),
                      completeButtonValidation: completeButtonValidation.asDriver(onErrorJustReturn: false),
                      uploadSuccessTrigger: uploadSuccessTrigger.asDriver(onErrorJustReturn: ()),
                      editSuccessTrigger: editSuccessTrigger.asDriver(onErrorJustReturn: ()),
                      cancelButtonTap: input.cancelButtonTap.asDriver(onErrorJustReturn: ()),
                      forbidden: forbidden.asDriver(onErrorJustReturn: ()),
                      badRequest: badRequest.asDriver(onErrorJustReturn: ()),
                      notFoundErr: notFoundErr.asDriver(onErrorJustReturn: ()),
                      unauthorized: unauthorized.asDriver(onErrorJustReturn: ()),
                      networkFail: networkFail.asDriver(onErrorJustReturn: ()))
    }
}
