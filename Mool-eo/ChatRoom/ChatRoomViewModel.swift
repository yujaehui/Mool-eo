//
//  ChattingViewModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/19/24.
//

import Foundation
import RxSwift
import RxCocoa

final class ChatRoomViewModel: ViewModelType {
    var disposeBag: DisposeBag = DisposeBag()
    let repository = ChatRepository()
    
    struct Input {
        let userId: Observable<String>
        let roomId: Observable<String>
        let newChat: Observable<String>
        let newChatUploadButtonTap: Observable<Void>
    }
    
    struct Output {
        let chatRoom: PublishSubject<ChatRoomModel>
        let chatList: Observable<[Chat]>
    }
    
    func transform(input: Input) -> Output {
        let chatRoom = PublishSubject<ChatRoomModel>()
        let beforChatListFetchSuccessTrigger = PublishSubject<Void>()
        let chatList = PublishSubject<[Chat]>()
            
        input.userId
            .map { userId in
                return ChatProduceQuery(opponent_id: userId)
            }
            .flatMap { query in
                NetworkManager.shared.chatProduce(query: query)
            }
            .debug("채팅 생성")
            .subscribe(with: self) { owner, value in
                switch value {
                case .success(let success): 
                    chatRoom.onNext(success)
                case .error(let error): 
                    print(error)
                }
            }.disposed(by: disposeBag)
        
        input.roomId
            .flatMap { roomId in
                Observable.from(optional: self.repository.fetchLatestChatByRoom(roomId))
                    .flatMap { chat in
                        NetworkManager.shared.chatHistoryCheck(roomId: roomId, cursorDate: chat.createdAt)
                    }
            }
            .debug("채팅 조회")
            .subscribe(with: self) { owner, value in
                switch value {
                case .success(let chatHistoryModel):
                    chatHistoryModel.data.forEach { chatModel in
                        self.manageChatSavingToRealm(chatModel)
                    }
                    beforChatListFetchSuccessTrigger.onNext(())
                case .error(let error):
                    print(error)
                }
            }
            .disposed(by: disposeBag)
        
        beforChatListFetchSuccessTrigger
            .withLatestFrom(input.roomId)
            .bind(with: self) { owner, roomId in
                chatList.onNext(owner.repository.fetchByRoom(roomId))
                SocketIOManager.shared.establishConnection(roomId)
            }.disposed(by: disposeBag)
        
        Observable.combineLatest(input.newChat, input.newChatUploadButtonTap)
            .map { value in
                return ChatSendQuery(content: value.0, files: nil)
            }
            .withLatestFrom(input.roomId) { query, roomId in
                return (query, roomId)
            }
            .flatMap { (query, roomId) in
                NetworkManager.shared.chatSend(query: query, roomId: roomId)
            }
            .debug("채팅 발송")
            .subscribe(with: self) { owner, value in
                switch value {
                case .success(let chatModel):
                    print(chatModel)
                case .error(let error):
                    print(error)
                }
            }.disposed(by: disposeBag)
        
        return Output(chatRoom: chatRoom, chatList: chatList)
    }
    
    private func manageChatSavingToRealm(_ chatModel: ChatModel) {
        let sender = Sender(user_id: chatModel.sender.userID, nick: chatModel.sender.nick, profileImage: chatModel.sender.profileImage)
        let data = Chat(chat_id: chatModel.chatID, room_id: chatModel.roomID, content: chatModel.content, createdAt: chatModel.createdAt, sender: sender, filesArray: chatModel.files)
        repository.createChat(data)
    }
}
