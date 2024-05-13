//
//  OtherUserProfileViewController.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/2/24.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import Toast

class OtherUserProfileViewController: BaseViewController {
    
    deinit {
        print("‼️OtherUserProfileViewController Deinit‼️")
    }
    
    let viewModel = OtherUserProfileViewModel()
    let otherUserProfileView = OtherUserProfileView()
    
    var userId: String = ""
    
    var reload = BehaviorSubject(value: ())
    var followStatus = PublishSubject<Bool>()
    
    private var sections = BehaviorSubject<[OtherUserProfileSectionModel]>(value: [])
    
    private let lastRow = PublishSubject<Int>()
    private let nextCursor = PublishSubject<String>()
    
    private var nickname: String = ""
    
    override func loadView() {
        self.view = otherUserProfileView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        registerObserver()
    }
    
    override func setNav() {
        navigationItem.backButtonTitle = ""
        navigationController?.navigationBar.tintColor = ColorStyle.point
    }
    
    override func bind() {
        sections.bind(to: otherUserProfileView.tableView.rx.items(dataSource: configureDataSource())).disposed(by: disposeBag)
        
        let modelSelected = otherUserProfileView.tableView.rx.modelSelected(OtherUserProfileSectionItem.self).asObservable()
        let itemSelected =  otherUserProfileView.tableView.rx.itemSelected.asObservable()
        let prefetch = otherUserProfileView.tableView.rx.prefetchRows.asObservable()
        let input = OtherUserProfileViewModel.Input(reload: reload, modelSelected: modelSelected, itemSelected: itemSelected, userId: userId, followStatus: followStatus, lastRow: lastRow, prefetch: prefetch, nextCursor: nextCursor)
        
        let output = viewModel.transform(input: input)
        output.result.bind(with: self) { owner, value in
            owner.nickname = value.0.nick
            owner.sections.onNext([OtherUserProfileSectionModel(title: nil, items: [.infoItem(value.0)])]
                                  + [OtherUserProfileSectionModel(title: "\(owner.nickname)의 상품", items: value.1.data.map { .product($0) })])
            guard value.1.nextCursor != "0" else { return }
            owner.nextCursor.onNext(value.1.nextCursor)
            let lastSection = owner.otherUserProfileView.tableView.numberOfSections - 1
            let lastRow = owner.otherUserProfileView.tableView.numberOfRows(inSection: lastSection) - 1
            owner.lastRow.onNext(lastRow)
        }.disposed(by: disposeBag)
        
        output.nextPostList.bind(with: self) { owner, value in
            owner.sections
                .take(1)
                .subscribe(onNext: { currentSections in
                    var updatedSections = currentSections
                    let updatedItems = updatedSections[1].items + value.data.map { .product($0) }
                    updatedSections[1] = OtherUserProfileSectionModel(title: "\(owner.nickname)의 상품", items: updatedItems)
                    owner.sections.onNext(updatedSections)
                    owner.otherUserProfileView.tableView.reloadData()
                    guard value.nextCursor != "0" else { return }
                    owner.nextCursor.onNext(value.nextCursor)
                    let lastSection = owner.otherUserProfileView.tableView.numberOfSections - 1
                    let lastRow = owner.otherUserProfileView.tableView.numberOfRows(inSection: lastSection) - 1
                    owner.lastRow.onNext(lastRow)
                })
                .disposed(by: owner.disposeBag)
        }.disposed(by: disposeBag)
        
        output.post.bind(with: self) { owner, value in
            let vc = PostDetailViewController()
            vc.postBoard = PostBoardType.allCases.first(where: { $0.rawValue == value.productId })!
            vc.postId = value.postId
            vc.userId = UserDefaultsManager.userId!
            owner.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: disposeBag)
        
        output.followOrUnfollowSuccessTrigger.drive(with: self) { owner, _ in
            owner.reload.onNext(()) // 새롭게 특정 게시글 조회 네트워크 통신 진행 (시점 전달)
            NotificationCenter.default.post(name: Notification.Name(Noti.changeProfile.rawValue), object: nil)
        }.disposed(by: disposeBag)
        
        output.notFoundErr.drive(with: self) { owner, _ in
            ToastManager.shared.showErrorToast(title: .notFoundErrFollow, in: owner.otherUserProfileView)
        }.disposed(by: disposeBag)
        
        output.networkFail.drive(with: self) { owner, _ in
            ToastManager.shared.showErrorToast(title: .networkFail, in: owner.otherUserProfileView)
        }.disposed(by: disposeBag)
    }
    
    func configureDataSource() -> RxTableViewSectionedReloadDataSource<OtherUserProfileSectionModel> {
        let dataSource = RxTableViewSectionedReloadDataSource<OtherUserProfileSectionModel>(configureCell: { dataSource, tableView, indexPath, item in
            switch item {
            case .infoItem(let info):
                let cell = tableView.dequeueReusableCell(withIdentifier: OtherUserProfileInfoTableViewCell.identifier, for: indexPath) as! OtherUserProfileInfoTableViewCell
                cell.configureCell(info)
                if info.followers.contains(where: { $0.user_id == UserDefaultsManager.userId }) {
                    cell.followButton.configuration = .check("팔로잉")
                    cell.followButton.rx.tap.bind(with: self) { owner, _ in
                        owner.followStatus.onNext(true)
                    }.disposed(by: cell.disposeBag)
                } else {
                    cell.followButton.configuration = .check2("팔로우")
                    cell.followButton.rx.tap.bind(with: self) { owner, _ in
                        owner.followStatus.onNext(false)
                    }.disposed(by: cell.disposeBag)
                }
                return cell
            case .product(let product):
                let cell = tableView.dequeueReusableCell(withIdentifier: ProfileProdcutTableViewCell.identifier, for: indexPath) as! ProfileProdcutTableViewCell
                cell.configureCell(product)
                return cell
            }
        }, titleForHeaderInSection: { dataSource, index in
            return dataSource.sectionModels[index].title
        })
        return dataSource
    }
    
    private func registerObserver() {
        Observable.of(
            NotificationCenter.default.rx.notification(Notification.Name(Noti.writePost.rawValue)),
            NotificationCenter.default.rx.notification(Notification.Name(Noti.changePost.rawValue))
        )
        .merge()
        .take(until: self.rx.deallocated)
        .subscribe(with: self) { owner, noti in
            owner.reload.onNext(())
        }
        .disposed(by: disposeBag)
    }
}
