//
//  ChatListViewController.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/19/24.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class ChatListViewController: BaseViewController {
    
    let viewModel = ChatListViewModel()
    let chatListView = ChatListView()
    
    private var reload = BehaviorSubject<Void>(value: ())
    private var sections = BehaviorSubject<[ChatListSectionModel]>(value: [])
    
    override func loadView() {
        self.view = chatListView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        registerObserver()
    }
    
    override func setNav() {
        super.setNav()
        navigationItem.title = "채팅"
    }
    
    override func configureView() {
        sections.bind(to: chatListView.tableView.rx.items(dataSource: configureDataSource())).disposed(by: disposeBag)
    }
    
    override func bind() {
        let input = ChatListViewModel.Input(
            reload: reload,
            modelSelected: chatListView.tableView.rx.modelSelected(ChatRoomModel.self).asObservable(),
            itemSelected: chatListView.tableView.rx.itemSelected.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.chatList.bind(with: self) { owner, value in
            owner.sections.onNext([ChatListSectionModel(items: value)])
        }.disposed(by: disposeBag)
        
        output.selectedChatRoom.bind(with: self) { owner, value in
            let vc = ChatRoomViewController()
            if let otherParticipant = value.participants.first(where: { $0.user_id != UserDefaultsManager.userId }) {
                vc.userId = otherParticipant.user_id
                vc.nickname = otherParticipant.nick
            }
            vc.hidesBottomBarWhenPushed = true
            owner.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: disposeBag)

        output.networkFail.drive(with: self) { owner, _ in
            ToastManager.shared.showErrorToast(title: .networkFail, in: owner.chatListView)
        }.disposed(by: disposeBag)
    }
    
    private func configureDataSource() -> RxTableViewSectionedReloadDataSource<ChatListSectionModel> {
        let dataSource = RxTableViewSectionedReloadDataSource<ChatListSectionModel> { dataSource, tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: ChatListTableViewCell.identifier, for: indexPath) as! ChatListTableViewCell
            cell.configureCell(item)
            return cell
        }
        return dataSource
    }
    
    private func registerObserver() {
        Observable.of(
            NotificationCenter.default.rx.notification(Notification.Name(Noti.newChat.rawValue)),
            NotificationCenter.default.rx.notification(Notification.Name(Noti.changeProfile.rawValue))
        )
        .merge()
        .take(until: self.rx.deallocated)
        .subscribe(with: self) { owner, noti in
            owner.reload.onNext(())
        }
        .disposed(by: disposeBag)
    }
}
