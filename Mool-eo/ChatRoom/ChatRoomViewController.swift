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
    
    var userId: String = ""
    
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
        let intput = ChatRoomViewModel.Input(userId: userId)
        
        let output = viewModel.transform(input: intput)
        output.chatProduceSuccessTrigger.bind(with: self) { owner, _ in
            print("채팅방 생성 성공")
        }.disposed(by: disposeBag)
    }
}
