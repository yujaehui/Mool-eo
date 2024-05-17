//
//  ProductCategoryViewModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/17/24.
//

import Foundation
import RxSwift
import RxCocoa

final class ProductCategoryViewModel: ViewModelType {
    var disposeBag: DisposeBag = DisposeBag()
    
    struct Input {
        let modelSelected: Observable<String>
        let itemSelected: Observable<IndexPath>
    }
    
    struct Output {
        let selectedCategory: PublishSubject<String>
    }
    
    func transform(input: Input) -> Output {
        let selectedCategory = PublishSubject<String>()
        
        Observable.zip(input.modelSelected, input.itemSelected)
            .map { $0.0 }
            .bind(with: self) { owner, value in
                selectedCategory.onNext(value)
            }.disposed(by: disposeBag)
        
        return Output(selectedCategory: selectedCategory)
    }
}
