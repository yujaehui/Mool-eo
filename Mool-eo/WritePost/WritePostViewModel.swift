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
        let postBoard: PostBoardType
        let content: Observable<String>
        let textViewBegin: Observable<Void>
        let textViewEnd: Observable<Void>
        let imageAddButtonTap: Observable<Void>
        let selectedImageDataSubject: PublishSubject<[Data]>
        let title: Observable<String>
        let completeButtonTap: Observable<Void>
    }
    
    struct Output {
        let text: Driver<String?>
        let textColorType: Driver<Bool>
        let imageAddButtonTap: Observable<Void>
        let uploadSuccessTrigger: PublishSubject<Void>
    }
    
    func transform(input: Input) -> Output {
        let placeholderText = "내용을 입력해주세요"
        let text = BehaviorRelay<String?>(value: placeholderText)
        let textColorType = BehaviorRelay<Bool>(value: false)
        let uploadSuccessTrigger = PublishSubject<Void>()
        
        input.textViewBegin
            .withLatestFrom(input.content)
            .bind(with: self) { owner, value in
                if value == text.value {
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
        
        let filesObservable = input.selectedImageDataSubject.map { files in
            return FilesQuery(files: files)
        }
        
        let postObservable = Observable.combineLatest(input.title, input.content).map { (title, content) in
            return PostQuery(title: title, content: content, product_id: input.postBoard.rawValue, files: nil)
        }
        
        input.completeButtonTap
            .withLatestFrom(filesObservable)
            .flatMap { filesQuery in
                return NetworkManager.imageUpload(query: filesQuery)
            }
            .withLatestFrom(postObservable) { filesModel, postObservable in
                return (filesModel, postObservable)
            }
            .map { filesModel, postObservable in
                return PostQuery(title: postObservable.title, content: postObservable.content, product_id: input.postBoard.rawValue, files: filesModel.files)
            }
            .flatMap { postQuery in
                return NetworkManager.postUpload(query: postQuery)
            }
            .debug("upload")
            .subscribe(with: self) { owner, _ in
                uploadSuccessTrigger.onNext(())
            } onError: { owner, error in
                print("오류 발생")
            }.disposed(by: disposeBag)
        
        return Output(text: text.asDriver(), textColorType: textColorType.asDriver(), imageAddButtonTap: input.imageAddButtonTap, uploadSuccessTrigger: uploadSuccessTrigger)
    }
}
