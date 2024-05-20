//
//  ChatListViewModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/19/24.
//

import Foundation
import RxSwift
import RxCocoa

class ChatListViewModel: ViewModelType {
    var disposeBag: DisposeBag = DisposeBag()
    
    struct Input {
        let reload: BehaviorSubject<Void>
    }
    
    struct Output {
        let chatList: PublishSubject<[ChatRoomModel]>
    }
    
    func transform(input: Input) -> Output {
        let chatList = PublishSubject<[ChatRoomModel]>()
        
        input.reload
            .flatMap { _ in
                NetworkManager.shared.chatListCheck()
            }
            .debug("채탱 내역 조회")
            .subscribe(with: self) { owner, value in
                switch value {
                case .success(let success): chatList.onNext(success.data)
                case .error(let error): print(error)
                }
            }.disposed(by: disposeBag)
        
        return Output(chatList: chatList)
    }
}
