//
//  WriteProductViewModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/10/24.
//

import Foundation
import RxSwift
import RxCocoa

final class WriteProductViewModel: ViewModelType {
    
    var disposeBag: DisposeBag = DisposeBag()
    
    struct Input {
        let textViewBegin: Observable<Void>
        let textViewEnd: Observable<Void>
        let selectedImageDataSubject: BehaviorSubject<[Data]>
        let productCategory: Observable<String>
        let productName: Observable<String>
        let productPrice: Observable<String>
        let productDetail: Observable<String>
        let imageAddButtonTap: Observable<Void>
        let completeButtonTap: Observable<Void>
    }
    
    struct Output {
        let text: Driver<String?>
        let textColorType: Driver<Bool>
        let imageAddButtonTap: Driver<Void>
        let convertedProductPrice: Driver<String>
        let completeButtonValidation: Driver<Bool>
        let uploadSuccessTrigger: PublishSubject<Void>
        let badRequest: Driver<Void>
        let notFoundErr: Driver<Void>
        let networkFail: Driver<Void>
    }
    
    func transform(input: Input) -> Output {
        let categoryText = "카테고리를 선택해주세요"
        let placeholderText = "내용을 입력해주세요"
        
        let text = BehaviorRelay<String?>(value: placeholderText)
        let textColorType = BehaviorRelay<Bool>(value: false)
        let originalProductPrice = PublishSubject<String>()
        let convertedProductPrice = PublishSubject<String>()
        let completeButtonValidation = BehaviorSubject(value: false)
        let uploadSuccessTrigger = PublishSubject<Void>()
        let badRequest = PublishSubject<Void>()
        let notFoundErr = PublishSubject<Void>()
        let networkFail = PublishSubject<Void>()
        
        input.textViewBegin
            .withLatestFrom(input.productDetail)
            .bind(with: self) { owner, value in
                if value == placeholderText {
                    text.accept(nil)
                    textColorType.accept(true)
                }
            }.disposed(by: disposeBag)
        
        input.textViewEnd
            .withLatestFrom(input.productDetail)
            .bind(with: self) { owner, value in
                if value.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    text.accept(placeholderText)
                    textColorType.accept(false)
                }
            }.disposed(by: disposeBag)
        
        input.productPrice
            .do { price in
                let originalValue = self.extractNumericString(from: price)
                originalProductPrice.onNext(originalValue)
            }
            .bind(with: self) { owner, priceString in
                convertedProductPrice.onNext(NumberFormatterManager.shared.formatCurrencyString(priceString))
            }.disposed(by: disposeBag)
        
        Observable.combineLatest(input.productCategory, input.productName, originalProductPrice, input.productDetail, input.selectedImageDataSubject)
            .map { (category, productName, price, detail, imageData) in
                return !productName.isEmpty && !price.isEmpty && !detail.isEmpty && !imageData.isEmpty && detail != placeholderText && category != categoryText
            }
            .bind(with: self) { owner, value in
                completeButtonValidation.onNext(value)
            }.disposed(by: disposeBag)
        
        let filesQuery = input.selectedImageDataSubject.map { files in
            return FilesQuery(files: files)
        }
        
        input.completeButtonTap
            .withLatestFrom(filesQuery)
            .flatMap { query in
                NetworkManager.shared.imageUpload(query: query)
            }
            .flatMapLatest { result -> Observable<PostQuery> in
                switch result {
                case .success(let filesModel):
                    return Observable.combineLatest(input.productCategory, input.productName, input.productPrice, input.productDetail).map { (category ,productName, price, detail) in
                        return PostQuery(title: productName,
                                         content: detail + HashtagManager.shared.convertToHashtagsAndUnderscore(category),
                                         content1: price,
                                         product_id: ProductIdentifier.product.rawValue,
                                         files: filesModel.files)
                    }
                case .error(let error):
                    switch error {
                    case .badRequest: badRequest.onNext(())
                    case .networkFail: networkFail.onNext(())
                    default: print("⚠️OTHER ERROR : \(error)⚠️")
                    }
                    return Observable.combineLatest(input.productName, input.productPrice, input.productDetail).map { (productName, price, detail) in
                        return PostQuery(title: productName, content: detail, content1: price, product_id: ProductIdentifier.product.rawValue, files: nil)
                    }
                }
            }
            .flatMap { query in
                NetworkManager.shared.postUpload(query: query)
            }
            .subscribe(with: self) { owner, value in
                switch value {
                case .success(_): uploadSuccessTrigger.onNext(())
                case .error(let error):
                    switch error {
                    case .notFoundErr: notFoundErr.onNext(())
                    case .networkFail: networkFail.onNext(())
                    default: print("⚠️OTHER ERROR : \(error)⚠️")
                    }
                }
            }.disposed(by: disposeBag)
        
        
        return Output(text: text.asDriver(onErrorJustReturn: ""),
                      textColorType: textColorType.asDriver(onErrorJustReturn: false),
                      imageAddButtonTap: input.imageAddButtonTap.asDriver(onErrorJustReturn: ()),
                      convertedProductPrice: convertedProductPrice.asDriver(onErrorJustReturn: ""),
                      completeButtonValidation: completeButtonValidation.asDriver(onErrorJustReturn: false),
                      uploadSuccessTrigger: uploadSuccessTrigger,
                      badRequest: badRequest.asDriver(onErrorJustReturn: ()),
                      notFoundErr: notFoundErr.asDriver(onErrorJustReturn: ()),
                      networkFail: networkFail.asDriver(onErrorJustReturn: ()))
    }
    
    private func extractNumericString(from input: String) -> String {
        return input.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
    }
}
