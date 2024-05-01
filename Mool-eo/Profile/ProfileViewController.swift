//
//  ProfileViewController.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/17/24.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

enum ProfileSectionItem {
    case infoItem(ProfileModel)
    case myPostItem(PostModel)
}

struct ProfileSectionModel {
    let title: String?
    var items: [ProfileSectionItem]
}

extension ProfileSectionModel: SectionModelType {
    typealias Item = ProfileSectionItem
    
    init(original: ProfileSectionModel, items: [ProfileSectionItem]) {
        self = original
        self.items = items
    }
}

class ProfileViewController: BaseViewController {
    
    let viewModel = ProfileViewModel()
    let profileView = ProfileView()
    
    var showProfileUpdateAlert: Bool = false
    
    override func loadView() {
        self.view = profileView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if showProfileUpdateAlert {
            profileView.makeToast("프로필 수정 성공", duration: 2, position: .top)
            showProfileUpdateAlert = false
        }
    }
    
    override func bind() {
        let viewDidLoad = Observable.just(())
        let modelSelected = profileView.tableView.rx.modelSelected(ProfileSectionItem.self).asObservable()
        let itemSelected = profileView.tableView.rx.itemSelected.asObservable()
        let input = ProfileViewModel.Input(viewDidLoad: viewDidLoad, modelSelected: modelSelected, itemSelected: itemSelected)
        
        let output = viewModel.transform(input: input)
        output.result.bind(with: self) { owner, value in
            let sections: [ProfileSectionModel] = [ProfileSectionModel(title: nil, items: [.infoItem(value.0)])]
            + value.1.data.map { myPost in
                ProfileSectionModel(title: "내 게시물", items: [.myPostItem(myPost)])
            }
            
            Observable.just(sections)
                .bind(to: owner.profileView.tableView.rx.items(dataSource: owner.configureDataSource()))
                .disposed(by: owner.disposeBag)
        }.disposed(by: disposeBag)
        
        output.post.drive(with: self) { owner, value in
            let vc = PostDetailViewController()
            vc.postId = value
            owner.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: disposeBag)
    }
    
    func configureDataSource() -> RxTableViewSectionedReloadDataSource<ProfileSectionModel> {
        let dataSource = RxTableViewSectionedReloadDataSource<ProfileSectionModel>(configureCell: { dataSource, tableView, indexPath, item in
            switch item {
            case .infoItem(let info):
                let cell = tableView.dequeueReusableCell(withIdentifier: ProfileInfoTableViewCell.identifier, for: indexPath) as! ProfileInfoTableViewCell
                cell.configureCell(info)
                cell.profileEditButton.rx.tap.bind(with: self) { owner, _ in
                    let vc = ProfileEditViewController()
                    vc.profileImageData = cell.profileImageView.image?.pngData()
                    vc.profileImage = info.profileImage
                    vc.nickname = info.nick
                    vc.introduction = info.introduction
                    owner.navigationController?.pushViewController(vc, animated: true)
                }.disposed(by: cell.disposeBag)
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
