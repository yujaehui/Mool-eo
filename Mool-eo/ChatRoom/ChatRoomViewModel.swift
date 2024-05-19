//
//  ChattingViewModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/19/24.
//

import Foundation
import RxSwift
import RxCocoa

class ChatRoomViewModel: ViewModelType {
    var disposeBag: DisposeBag = DisposeBag()
    
    struct Input {
        let userId: Observable<String>
    }
    
    struct Output {
        let chatProduceSuccessTrigger: PublishSubject<Void>
    }
    
    func transform(input: Input) -> Output {
        let chatProduceSuccessTrigger = PublishSubject<Void>()
        
        input.userId
            .map { userId in
                return ChatProduceQuery(opponent_id: userId)
            }
            .flatMap { query in
                NetworkManager.shared.chatProduce(query: query)
            }
            .debug("채팅방 생성")
            .subscribe(with: self) { owner, value in
                switch value {
                case .success(let success): chatProduceSuccessTrigger.onNext(())
                case .error(let error): print(error)
                }
            }.disposed(by: disposeBag)
        
        return Output(chatProduceSuccessTrigger: chatProduceSuccessTrigger)
    }
}
