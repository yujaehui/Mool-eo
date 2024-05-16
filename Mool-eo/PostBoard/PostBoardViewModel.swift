//
//  PostBoardViewModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/13/24.
//

import Foundation
import RxSwift
import RxCocoa

//class PostBoardViewModel: ViewModelType {
//    
//    var disposeBag: DisposeBag = DisposeBag()
//    
//    struct Input {
//        let modelSelected: Observable<PostBoardType>
//        let itemSelected: Observable<IndexPath>
//    }
//    
//    struct Output {
//        let selectPostBoard: Driver<PostBoardType>
//    }
//    
//    func transform(input: Input) -> Output {
//        let selectPostBoard = PublishSubject<PostBoardType>()
//        
//        Observable.zip(input.modelSelected, input.itemSelected)
//            .map { $0.0 }
//            .bind(with: self) { owner, value in
//                selectPostBoard.onNext(value)
//            }.disposed(by: disposeBag)
//        
//        return Output(selectPostBoard: selectPostBoard.asDriver(onErrorJustReturn: .free))
//    }
//}
