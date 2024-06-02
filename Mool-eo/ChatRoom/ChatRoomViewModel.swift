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
        let newChatListSubject: PublishSubject<[Chat]>
    }
    
    func transform(input: Input) -> Output {
        let chatRoom = PublishSubject<ChatRoomModel>()
        let beforChatListFetchSuccessTrigger = PublishSubject<Void>()
        let chatList = PublishSubject<[Chat]>()
        
        var newChatList: [Chat] = []
        let newChatListSubject = PublishSubject<[Chat]>()
            
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
                case .success(let chatRoomModel):
                    chatRoom.onNext(chatRoomModel)
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
                case .success(let chat):
                    newChatList.append(chat)
                    newChatListSubject.onNext(newChatList)
                case .error(let error):
                    print(error)
                }
            }.disposed(by: disposeBag)
        
        SocketIOManager.shared.receivedChatData
            .subscribe(with: self) { owner, chat in
                newChatList.append(chat)
                newChatListSubject.onNext(newChatList)
            }.disposed(by: disposeBag)
        
        return Output(chatRoom: chatRoom, chatList: chatList, newChatListSubject: newChatListSubject)
    }
    
    private func manageChatSavingToRealm(_ chat: Chat) {
        if let chatSender = chat.sender {
            let sender = Sender(user_id: chatSender.user_id, nick: chatSender.nick, profileImage: chatSender.profileImage)
            let data = Chat(chat_id: chat.chat_id, room_id: chat.room_id, content: chat.content, createdAt: chat.createdAt, sender: sender, filesArray: chat.filesArray)
            repository.createChat(data)
        }
    }
}
