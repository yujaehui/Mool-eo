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
    
    var reload = BehaviorSubject(value: ())
    var followStatus = PublishSubject<Bool>()
    
    private var sections = BehaviorSubject<[OtherUserProfileSectionModel]>(value: [])
    
    private var nickname: String = ""
    var userId: String = ""
    
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
        sections.bind(to: otherUserProfileView.collectionView.rx.items(dataSource: configureDataSource())).disposed(by: disposeBag)
        
        let modelSelected = otherUserProfileView.collectionView.rx.modelSelected(OtherUserProfileSectionItem.self).asObservable()
        let itemSelected =  otherUserProfileView.collectionView.rx.itemSelected.asObservable()
        let input = OtherUserProfileViewModel.Input(reload: reload, modelSelected: modelSelected, itemSelected: itemSelected, userId: userId, followStatus: followStatus)
        
        let output = viewModel.transform(input: input)
        output.result.bind(with: self) { owner, value in
            owner.nickname = value.0.nick
            
            var sectionModels: [OtherUserProfileSectionModel] = []
            
            sectionModels.append(OtherUserProfileSectionModel(title: nil, items: [.infoItem(value.0)]))
            
            if !value.1.data.isEmpty {
                owner.otherUserProfileView.sections.insert(.product, at: 1)
                let productSection = OtherUserProfileSectionModel(title: "판매 중인 상품", items: value.1.data.map { .product($0) })
                sectionModels.append(productSection)
            } else {
                owner.otherUserProfileView.sections.insert(.empty, at: 1)
                sectionModels.append(OtherUserProfileSectionModel(title: "판매 중인 상품", items: [.noProduct]))
            }
            
            if !value.2.data.isEmpty {
                owner.otherUserProfileView.sections.insert(.post, at: 2)
                let postSection = OtherUserProfileSectionModel(title: "작성한 게시글", items: value.2.data.map { .post($0) })
                sectionModels.append(postSection)
            } else {
                owner.otherUserProfileView.sections.insert(.empty, at: 2)
                sectionModels.append(OtherUserProfileSectionModel(title: "작성한 게시글", items: [.noPost]))
            }
            
            owner.sections.onNext(sectionModels)
        }.disposed(by: disposeBag)
        
        output.post.bind(with: self) { owner, value in
            let vc = PostDetailViewController()
            vc.postBoard = ProductIdentifier.post
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
    
    func configureDataSource() -> RxCollectionViewSectionedReloadDataSource<OtherUserProfileSectionModel> {
        let dataSource = RxCollectionViewSectionedReloadDataSource<OtherUserProfileSectionModel>(configureCell: { dataSource, collectionView, indexPath, item in
            switch item {
            case .infoItem(let info):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OtherUserProfileInfoCollectionViewCell.identifier, for: indexPath) as! OtherUserProfileInfoCollectionViewCell
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
                cell.chatButton.rx.tap.bind(with: self) { owner, _ in
                    let vc = ChatRoomViewController()
                    vc.userId = info.user_id
                    owner.navigationController?.pushViewController(vc, animated: true)
                }.disposed(by: cell.disposeBag)
                return cell
            case .product(let product):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserProfileProductCollectionViewCell.identifier, for: indexPath) as! UserProfileProductCollectionViewCell
                cell.configureCell(item: product)
                return cell
            case .post(let post):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserProfilePostCollectionViewCell.identifier, for: indexPath) as! UserProfilePostCollectionViewCell
                cell.configureCell(myPost: post)
                return cell
            case .noProduct:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmptyCollectionViewCell.identifier, for: indexPath) as! EmptyCollectionViewCell
                cell.emptyLabel.text = "상품이 없습니다"
                return cell
            case .noPost:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmptyCollectionViewCell.identifier, for: indexPath) as! EmptyCollectionViewCell
                cell.emptyLabel.text = "게시글이 없습니다"
                return cell
            }
        },configureSupplementaryView: { dataSource, collectionView, kind, indexPath in
            switch kind {
            case UICollectionView.elementKindSectionHeader:
                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderCollectionReusableView.identifier, for: indexPath) as! HeaderCollectionReusableView
                headerView.headerLabel.text = dataSource[indexPath.section].title
                switch dataSource[indexPath.section].items[indexPath.item] {
                case .product(let product):
                    headerView.seeMoreButton.rx.tap.bind(with: self) { owner, _ in
                        let vc = ProfileProductListViewController()
                        vc.userId = product.creator.userId
                        vc.nickname = product.creator.nick
                        owner.navigationController?.pushViewController(vc, animated: true)
                    }.disposed(by: headerView.disposeBag)
                case .post(let post):
                    headerView.seeMoreButton.rx.tap.bind(with: self) { owner, _ in
                        let vc = ProfilePostListViewController()
                        vc.userId = post.creator.userId
                        vc.nickname = post.creator.nick
                        owner.navigationController?.pushViewController(vc, animated: true)
                    }.disposed(by: headerView.disposeBag)
                default: break
                }
                return headerView
            default:
                fatalError("Unexpected element kind")
            }
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
