//
//  ChatRoomViewController.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/19/24.
//

import UIKit
import RxSwift
import RxCocoa

class ChatRoomViewController: BaseViewController {
    
    let viewModel = ChatRoomViewModel()
    let chatRoomView = ChatRoomView()
    
    var reload = BehaviorSubject<Void>(value: ())
    var userId: String = ""
    var roomId = PublishSubject<String>()
    
    override func loadView() {
        self.view = chatRoomView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setNav() {
        
    }
    
    override func bind() {
        let userId = Observable.just(userId)
        let roomId = roomId
        let newChat = chatRoomView.wirteTextView.wirteTextView.rx.text.orEmpty.asObservable()
        let newChatUploadButtonTap = chatRoomView.wirteTextView.textUploadButton.rx.tap.asObservable()
        let intput = ChatRoomViewModel.Input(userId: userId, roomId: roomId, newChat: newChat, newChatUploadButtonTap: newChatUploadButtonTap)
        
        let output = viewModel.transform(input: intput)
        output.chatProduceSuccessTrigger.bind(with: self) { owner, value in
            owner.roomId.onNext(value.roomID)
        }.disposed(by: disposeBag)
    }
}
