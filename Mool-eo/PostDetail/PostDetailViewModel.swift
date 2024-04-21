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
        let viewDidLoadTrigger: Observable<String>
    }
    
    struct Output {
        let postDetail: PublishSubject<PostModel>
    }
    
    func transform(input: Input) -> Output {
        let postDetail = PublishSubject<PostModel>()
        
        input.viewDidLoadTrigger
            .flatMap { value in
                NetworkManager.postCheckSpecific(postId: value)
            }
            .debug("postDetail")
            .subscribe(with: self) { owner, value in
                postDetail.onNext(value)
            }.disposed(by: disposeBag)
        
        return Output(postDetail: postDetail)
    }
}
