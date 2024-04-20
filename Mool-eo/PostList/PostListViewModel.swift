//
//  PostListViewModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/20/24.
//

import Foundation
import RxSwift
import RxCocoa

class PostListViewModel: ViewModelType {
    var disposeBag: DisposeBag = DisposeBag()
    
    struct Input {
        let viewDidLoadTrigger: Observable<PostBoardType>
        let postWriteButtonTap: Observable<Void>
    }
    
    struct Output {
        let postList: PublishSubject<[postData]>
        let postWriteButtonTap: Observable<Void>
    }
    
    func transform(input: Input) -> Output {
        let postList = PublishSubject<[postData]>()
        
        input.viewDidLoadTrigger.flatMap { value in
            NetworkManager.postCheck(productId: value.rawValue)
        }
        .debug()
        .subscribe(with: self) { owner, value in
            postList.onNext(value.data)
        }.disposed(by: disposeBag)
        
        
        return Output(postList: postList, postWriteButtonTap: input.postWriteButtonTap)
    }
}
