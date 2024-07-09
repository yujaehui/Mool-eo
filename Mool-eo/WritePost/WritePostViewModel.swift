//
//  WritePostViewModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/10/24.
//

import Foundation
import RxSwift
import RxCocoa

final class WritePostViewModel: ViewModelType {
    
    var disposeBag: DisposeBag = DisposeBag()
    
    struct Input {
        let contentTextViewBegin: Observable<Void>
        let contentTextViewEnd: Observable<Void>
        let title: Observable<String>
        let content: Observable<String>
        let selectedImageDataSubject: BehaviorSubject<[Data]>
        let imageAddButtonTap: Observable<Void>
        let completeButtonTap: Observable<Void>
        let type: PostInteractionType
        let postId: Observable<String>
    }
    
    struct Output {
        let contentText: Driver<String?>
        let contentTextColorType: Driver<Bool>
        let imageAddButtonTap: Driver<Void>
        let completeButtonValidation: Driver<Bool>
        let uploadSuccessTrigger: Driver<Void>
        let editSuccessTrigger: Driver<Void>
        let networkFail: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        let placeholderText = "내용을 입력해주세요"
        let contentText = PublishRelay<String?>()
        let contentTextColorType = PublishRelay<Bool>()
        let completeButtonValidation = BehaviorSubject(value: false)
        let filesModelSubject = PublishSubject<FilesModel>()
        let uploadSuccessTrigger = PublishSubject<Void>()
        let editSuccessTrigger = PublishSubject<Void>()
        let networkFail = PublishSubject<Void>()
        
        handleContentTextView(input: input, text: contentText, textColorType: contentTextColorType, placeholderText: placeholderText)
        validateCompleteButton(input: input, placeholderText: placeholderText, completeButtonValidation: completeButtonValidation)
        
        switch input.type {
        case .upload: handleUpload(input: input, filesModelSubject: filesModelSubject, uploadSuccessTrigger: uploadSuccessTrigger, networkFail: networkFail)
        case .edit: handleEdit(input: input, editSuccessTrigger: editSuccessTrigger, networkFail: networkFail)
        }
        
        return Output(contentText: contentText.asDriver(onErrorJustReturn: ""),
                      contentTextColorType: contentTextColorType.asDriver(onErrorJustReturn: false),
                      imageAddButtonTap: input.imageAddButtonTap.asDriver(onErrorJustReturn: ()),
                      completeButtonValidation: completeButtonValidation.asDriver(onErrorJustReturn: false),
                      uploadSuccessTrigger: uploadSuccessTrigger.asDriver(onErrorJustReturn: ()),
                      editSuccessTrigger: editSuccessTrigger.asDriver(onErrorJustReturn: ()),
                      networkFail: networkFail.asDriver(onErrorJustReturn: ()))
    }
    
    private func handleContentTextView(input: Input, text: PublishRelay<String?>, textColorType: PublishRelay<Bool>, placeholderText: String) {
        input.contentTextViewBegin
            .withLatestFrom(input.content)
            .bind { value in
                if value == placeholderText {
                    text.accept(nil)
                    textColorType.accept(true)
                }
            }.disposed(by: disposeBag)
        
        input.contentTextViewEnd
            .withLatestFrom(input.content)
            .bind { value in
                if value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    text.accept(placeholderText)
                    textColorType.accept(false)
                }
            }.disposed(by: disposeBag)
    }
    
    private func validateCompleteButton(input: Input, placeholderText: String, completeButtonValidation: BehaviorSubject<Bool>) {
        Observable.combineLatest(input.title, input.content)
            .map { !$0.isEmpty && !$1.isEmpty && $1 != placeholderText }
            .bind(to: completeButtonValidation)
            .disposed(by: disposeBag)
    }
    
    private func postUploadWithoutImage(input: Input, uploadSuccessTrigger: PublishSubject<Void>, networkFail: PublishSubject<Void>) {
        Observable.combineLatest(input.title, input.content)
            .map { PostQuery(title: $0.0, content: $0.1, content1: nil, product_id: ProductIdentifier.post.rawValue, files: nil) }
            .flatMap { NetworkManager.shared.postUpload(query: $0) }
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(_): uploadSuccessTrigger.onNext(())
                case .error(let error): owner.handleNetworkError(error: error, networkFail: networkFail)
                }
            }
            .disposed(by: disposeBag)
    }
    
    private func imageUpload(input: Input, filesModelSubject: PublishSubject<FilesModel>, networkFail: PublishSubject<Void>) {
        input.selectedImageDataSubject
            .filter { !$0.isEmpty }
            .map { FilesQuery(files: $0) }
            .flatMap { NetworkManager.shared.imageUpload(query: $0) }
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(let filesModel): filesModelSubject.onNext(filesModel)
                case .error(let error): owner.handleNetworkError(error: error, networkFail: networkFail)
                }
            }
            .disposed(by: disposeBag)
    }
    
    private func postUpload(input: Input, filesModelSubject: PublishSubject<FilesModel>, uploadSuccessTrigger: PublishSubject<Void>, networkFail: PublishSubject<Void>) {
        filesModelSubject
            .withLatestFrom(Observable.combineLatest(input.title, input.content)) { filesModel, post in
                return PostQuery(title: post.0, content: post.1, content1: nil, product_id: ProductIdentifier.post.rawValue, files: filesModel.files)
            }
            .flatMap { NetworkManager.shared.postUpload(query: $0) }
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(_): uploadSuccessTrigger.onNext(())
                case .error(let error): owner.handleNetworkError(error: error, networkFail: networkFail)
                }
            }
            .disposed(by: disposeBag)
    }
    
    private func handleUpload(input: Input, filesModelSubject: PublishSubject<FilesModel>, uploadSuccessTrigger: PublishSubject<Void>, networkFail: PublishSubject<Void>) {
        input.completeButtonTap
            .withLatestFrom(input.selectedImageDataSubject)
            .map { $0.isEmpty }
            .bind(with: self) { owner, value in
                if value {
                    owner.postUploadWithoutImage(input: input, uploadSuccessTrigger: uploadSuccessTrigger, networkFail: networkFail)
                } else {
                    owner.imageUpload(input: input, filesModelSubject: filesModelSubject, networkFail: networkFail)
                    owner.postUpload(input: input, filesModelSubject: filesModelSubject, uploadSuccessTrigger: uploadSuccessTrigger, networkFail: networkFail)
                }
            }
            .disposed(by: disposeBag)
    }
    
    private func handleEdit(input: Input, editSuccessTrigger: PublishSubject<Void>, networkFail: PublishSubject<Void>) {
        input.completeButtonTap
            .withLatestFrom(Observable.combineLatest(input.title, input.content))
            .map { PostQuery(title: $0.0, content: $0.1, content1: nil, product_id: ProductIdentifier.post.rawValue, files: nil) }
            .withLatestFrom(input.postId) { query, postId in
                return (query, postId)
            }
            .flatMap { NetworkManager.shared.postEdit(query: $0.0, postId: $0.1) }
            .subscribe(with: self) { owner, result in
                switch result {
                case .success(_): editSuccessTrigger.onNext(())
                case .error(let error): owner.handleNetworkError(error: error, networkFail: networkFail)
                }
            }
            .disposed(by: disposeBag)
        
    }
    
    private func handleNetworkError(error: NetworkError, networkFail: PublishSubject<Void>) {
        switch error {
        case .networkFail: networkFail.onNext(())
        default: print("⚠️OTHER ERROR : \(error)⚠️")
        }
    }
}
