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
import Toast

class ProfileViewController: BaseViewController {
    
    deinit {
        print("‼️ProfileViewController Deinit‼️")
    }
    
    let viewModel = ProfileViewModel()
    let profileView = ProfileView()
    
    var showProfileUpdateAlert: Bool = false
    
    var reload = BehaviorSubject(value: ())
    private var settingButtonTap = PublishSubject<Void>()
    
    private var sections = BehaviorSubject<[ProfileSectionModel]>(value: [])
    private lazy var dataSource = configureDataSource()
    
    private let lastRow = PublishSubject<Int>()
    private let nextCursor = PublishSubject<String>()
    
    override func loadView() {
        self.view = profileView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerObserver()
    }
    
    override func setNav() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gearshape"), style: .plain, target: self, action: #selector(rightBarButtonTapped))
        navigationItem.backButtonTitle = ""
        navigationController?.navigationBar.tintColor = ColorStyle.point
    }
    
    @objc func rightBarButtonTapped() {
        settingButtonTap.onNext(())
    }
    
    override func bind() {
        sections.bind(to: profileView.tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
        profileView.tableView.rx.setDelegate(self).disposed(by: disposeBag)
        
        let reload = reload
        let modelSelected = profileView.tableView.rx.modelSelected(ProfileSectionItem.self).asObservable()
        let itemSelected = profileView.tableView.rx.itemSelected.asObservable()
        let prefetch = profileView.tableView.rx.prefetchRows.asObservable()
        let settingButtonTap = settingButtonTap
        let input = ProfileViewModel.Input(reload: reload, modelSelected: modelSelected, itemSelected: itemSelected, lastRow: lastRow, prefetch: prefetch, nextCursor: nextCursor, settingButtonTap: settingButtonTap)
        
        let output = viewModel.transform(input: input)
        output.result.bind(with: self) { owner, value in
            owner.sections.onNext([ProfileSectionModel(title: nil, items: [.infoItem(value.0)])]
                                  + [ProfileSectionModel(title: "내가 판매 중인 상품", items: value.1.data.map { .product($0) })])
            guard value.1.nextCursor != "0" else { return }
            owner.nextCursor.onNext(value.1.nextCursor)
            let lastSection = owner.profileView.tableView.numberOfSections - 1
            let lastRow = owner.profileView.tableView.numberOfRows(inSection: lastSection) - 1
            owner.lastRow.onNext(lastRow)
        }.disposed(by: disposeBag)
        
        output.nextPostList.bind(with: self) { owner, value in
            owner.sections
                .take(1)
                .subscribe(onNext: { currentSections in
                    var updatedSections = currentSections
                    let updatedItems = updatedSections[1].items + value.data.map { .product($0) }
                    updatedSections[1] = ProfileSectionModel(title: "내가 판매 중인 상품", items: updatedItems)
                    owner.sections.onNext(updatedSections)
                    owner.profileView.tableView.reloadData()
                    guard value.nextCursor != "0" else { return }
                    owner.nextCursor.onNext(value.nextCursor)
                    let lastSection = owner.profileView.tableView.numberOfSections - 1
                    let lastRow = owner.profileView.tableView.numberOfRows(inSection: lastSection) - 1
                    owner.lastRow.onNext(lastRow)
                })
                .disposed(by: owner.disposeBag)
        }.disposed(by: disposeBag)

        
        output.post.bind(with: self) { owner, value in
            let vc = ProductPostDetailViewController()
            vc.postId = value.postId
            owner.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: disposeBag)

        
        output.networkFail.drive(with: self) { owner, _ in
            ToastManager.shared.showErrorToast(title: .networkFail, in: owner.profileView)
        }.disposed(by: disposeBag)
        
        output.settingButtonTap.bind(with: self) { owner, _ in
            let vc = SettingViewController()
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
            NotificationCenter.default.rx.notification(Notification.Name(Noti.changePost.rawValue)),
            NotificationCenter.default.rx.notification(Notification.Name(Noti.changeProfile.rawValue))
        )
        .merge()
        .take(until: self.rx.deallocated)
        .subscribe(with: self) { owner, noti in
            owner.reload.onNext(())
            if (noti.object as? Bool) != nil {
                ToastManager.shared.showToast(title: "프로필이 수정되었습니다", in: owner.profileView)
            }
        }
        .disposed(by: disposeBag)
    }
}

extension ProfileViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0: return 0
        default: return 50
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0: return nil
        default:
            let title = dataSource[section]
            let view = ProfileMyPostHeaderView()
            view.myPostLabel.text = title.title
            return view
        }
    }
}
