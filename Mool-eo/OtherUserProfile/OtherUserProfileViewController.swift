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

enum OtherUserProfileSectionItem {
    case infoItem(OtherUserProfileModel)
    case myPostItem(PostModel)
}

struct OtherUserProfileSectionModel {
    let title: String?
    var items: [OtherUserProfileSectionItem]
}

extension OtherUserProfileSectionModel: SectionModelType {
    typealias Item = OtherUserProfileSectionItem
    
    init(original: OtherUserProfileSectionModel, items: [OtherUserProfileSectionItem]) {
        self = original
        self.items = items
    }
}

class OtherUserProfileViewController: BaseViewController {
    
    let viewModel = OtherUserProfileViewModel()
    let otherUserProfileView = OtherUserProfileView()
    
    var userId: String = ""
    
    var reload = BehaviorSubject(value: ())
    var followStatus = PublishSubject<Bool>()
    
    private var sections = BehaviorSubject<[OtherUserProfileSectionModel]>(value: [])
    
    override func loadView() {
        self.view = otherUserProfileView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func bind() {
        sections.bind(to: otherUserProfileView.tableView.rx.items(dataSource: configureDataSource())).disposed(by: disposeBag)
        
        let input = OtherUserProfileViewModel.Input(reload: reload, userId: userId, followStatus: followStatus)
        
        let output = viewModel.transform(input: input)
        output.result.bind(with: self) { owner, value in
            owner.sections.onNext([OtherUserProfileSectionModel(title: nil, items: [.infoItem(value.0)])]
                                  + [OtherUserProfileSectionModel(title: "\(value.0.nick)의 게시물", items: value.1.data.map { .myPostItem($0) })])
        }.disposed(by: disposeBag)
        
        output.followOrUnfollowSuccessTrigger.drive(with: self) { owner, _ in
            owner.otherUserProfileView.tableView.reloadData()
            owner.reload.onNext(()) // 새롭게 특정 게시글 조회 네트워크 통신 진행 (시점 전달)
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
            case .myPostItem(let myPost):
                if myPost.files.isEmpty {
                    let cell = tableView.dequeueReusableCell(withIdentifier: ProfileMyPostWithoutImageTableViewCell.identifier, for: indexPath) as! ProfileMyPostWithoutImageTableViewCell
                    cell.configureCell(myPost: myPost)
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: ProfileMyPostTableViewCell.identifier, for: indexPath) as! ProfileMyPostTableViewCell
                    cell.configureCell(myPost: myPost)
                    return cell
                }
            }
        }, titleForHeaderInSection: { dataSource, index in
            return dataSource.sectionModels[index].title
        })
        return dataSource
    }
}
