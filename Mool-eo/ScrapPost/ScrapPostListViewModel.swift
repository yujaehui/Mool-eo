//
//  ScrapPostListViewModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/1/24.
//

import Foundation
import RxSwift
import RxCocoa

class ScrapPostListViewModel: ViewModelType {
    var disposeBag: DisposeBag = DisposeBag()
    
    struct Input {
        let viewDidLoad: Observable<Void>
    }
    
    struct Output {
        let scrapPostList: PublishSubject<[PostModel]>
    }
    
    func transform(input: Input) -> Output {
        let scrapPostList = PublishSubject<[PostModel]>()
        
        input.viewDidLoad
            .flatMap { _ in
                NetworkManager.shared.scrapPostCheck()
            }
            .debug("스크랩 게시물 조회")
            .subscribe(with: self) { owner, value in
                scrapPostList.onNext(value.data)
            } onError: { owner, error in
                print("오류 발생")
            }.disposed(by: disposeBag)
        
        return Output(scrapPostList: scrapPostList)
    }
}
