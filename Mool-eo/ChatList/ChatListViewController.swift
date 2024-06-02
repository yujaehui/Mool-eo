//
//  ChatListViewController.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/19/24.
//

import UIKit
import RxSwift
import RxCocoa

class ChatListViewController: BaseViewController {
    
    let viewModel = ChatListViewModel()
    let chatListView = ChatListView()
    
    private var reload = BehaviorSubject<Void>(value: ())
    
    override func loadView() {
        self.view = chatListView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setNav() {
        navigationItem.title = "채팅"
        navigationItem.backButtonTitle = ""
        navigationController?.navigationBar.tintColor = ColorStyle.point
    }
    
    override func bind() {
        let reload = reload
        let modelSelected = chatListView.tableView.rx.modelSelected(ChatRoomModel.self).asObservable()
        let itemSelected = chatListView.tableView.rx.itemSelected.asObservable()
        let input = ChatListViewModel.Input(reload: reload, modelSelected: modelSelected, itemSelected: itemSelected)
        
        let output = viewModel.transform(input: input)
        output.chatList.bind(to: chatListView.tableView.rx.items(cellIdentifier: ChatListTableViewCell.identifier, cellType: ChatListTableViewCell.self)) { (row, element, cell) in
            cell.configureCell(element)
        }.disposed(by: disposeBag)
        
        output.selectedChatRoom.bind(with: self) { owner, value in
            let vc = ChatRoomViewController()
            if let otherParticipant = value.participants.first(where: { $0.user_id != UserDefaultsManager.userId }) {
                vc.userId = otherParticipant.user_id
            }
            vc.hidesBottomBarWhenPushed = true
            owner.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: disposeBag)

    }
}
