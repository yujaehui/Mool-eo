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

final class OtherUserProfileViewController: BaseViewController {
    
    deinit { print("‼️OtherUserProfileViewController Deinit‼️") }
    
    let viewModel = OtherUserProfileViewModel()
    let otherUserProfileView = OtherUserProfileView()
    
    private var reload = BehaviorSubject(value: ())
    private var followStatus = PublishSubject<Bool>()
    private var sections = BehaviorSubject<[OtherUserProfileSectionModel]>(value: [])
    var nickname: String = ""
    var userId: String = ""
    
    override func loadView() {
        self.view = otherUserProfileView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        registerObserver()
    }
    
    override func setNav() {
        navigationItem.title = "\(nickname)의 프로필"
    }
    
    override func configureView() {
        sections.bind(to: otherUserProfileView.collectionView.rx.items(dataSource: configureDataSource())).disposed(by: disposeBag)
    }
    
    override func bind() {
        let input = OtherUserProfileViewModel.Input(
            reload: reload,
            modelSelected: otherUserProfileView.collectionView.rx.modelSelected(OtherUserProfileSectionItem.self).asObservable(),
            itemSelected: otherUserProfileView.collectionView.rx.itemSelected.asObservable(),
            userId: userId,
            followStatus: followStatus
        )
        
        let output = viewModel.transform(input: input)
        output.result.bind(with: self) { owner, value in
            owner.configureSections(value)
        }.disposed(by: disposeBag)
        
        output.productDetail.bind(with: self) { owner, product in
            owner.navigateToProductDetail(product)
        }.disposed(by: disposeBag)
        
        output.postDetail.bind(with: self) { owner, post in
            owner.navigateToPostDetail(post)
        }.disposed(by: disposeBag)
        
        output.followOrUnfollowSuccessTrigger.drive(with: self) { owner, _ in
            NotificationCenter.default.post(name: Notification.Name(Noti.changeProfile.rawValue), object: nil)
            owner.reload.onNext(())
        }.disposed(by: disposeBag)
        
        output.networkFail.drive(with: self) { owner, _ in
            ToastManager.shared.showErrorToast(title: .networkFail, in: owner.otherUserProfileView)
        }.disposed(by: disposeBag)
    }
    
    private func configureDataSource() -> RxCollectionViewSectionedReloadDataSource<OtherUserProfileSectionModel> {
        return RxCollectionViewSectionedReloadDataSource<OtherUserProfileSectionModel>(
            configureCell: { [weak self] dataSource, collectionView, indexPath, item in
                guard let self = self else { return UICollectionViewCell() }
                return self.configureCell(dataSource, collectionView, indexPath, item)
            },
            configureSupplementaryView: { [weak self] dataSource, collectionView, kind, indexPath in
                guard let self = self else { return UICollectionReusableView() }
                return self.configureSupplementaryView(dataSource, collectionView, kind, indexPath)
            }
        )
    }
    
    private func configureCell(_ dataSource: CollectionViewSectionedDataSource<OtherUserProfileSectionModel>, _ collectionView: UICollectionView, _ indexPath: IndexPath, _ item: OtherUserProfileSectionItem) -> UICollectionViewCell {
            switch item {
            case .infoItem(let info):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: OtherUserProfileInfoCollectionViewCell.identifier, for: indexPath) as! OtherUserProfileInfoCollectionViewCell
                cell.configureCell(info)
                if info.followers.contains(where: { $0.user_id == UserDefaultsManager.userId }) {
                    cell.followButton.rx.tap.bind(with: self) { owner, _ in
                        owner.followStatus.onNext(true)
                    }.disposed(by: cell.disposeBag)
                } else {
                    cell.followButton.rx.tap.bind(with: self) { owner, _ in
                        owner.followStatus.onNext(false)
                    }.disposed(by: cell.disposeBag)
                }
                cell.chatButton.rx.tap.bind(with: self) { owner, _ in
                    owner.navigateToChatRoom(info.user_id)
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
        }
    
    private func configureSupplementaryView(_ dataSource: CollectionViewSectionedDataSource<OtherUserProfileSectionModel>, _ collectionView: UICollectionView, _ kind: String, _ indexPath: IndexPath) -> UICollectionReusableView {
            switch kind {
            case UICollectionView.elementKindSectionHeader:
                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderCollectionReusableView.identifier, for: indexPath) as! HeaderCollectionReusableView
                headerView.headerLabel.text = dataSource[indexPath.section].title
                switch dataSource[indexPath.section].items[indexPath.item] {
                case .noProduct, .noPost: headerView.seeMoreButton.isHidden = true
                default: setupHeaderButton(for: headerView, with: dataSource[indexPath.section].items[indexPath.item])
                }
                return headerView
            default:
                fatalError("Unexpected element kind")
            }
        }
    
    private func setupHeaderButton(for headerView: HeaderCollectionReusableView, with item: OtherUserProfileSectionItem) {
            switch item {
            case .product(let product):
                headerView.seeMoreButton.rx.tap.bind(with: self) { owner, _ in
                    owner.navigateToProductList(product.creator)
                }.disposed(by: headerView.disposeBag)
            case .post(let post):
                headerView.seeMoreButton.rx.tap.bind(with: self) { owner, _ in
                    owner.navigateToPostList(post.creator)
                }.disposed(by: headerView.disposeBag)
            default: break
            }
        }
    
    private func configureSections(_ value: (OtherUserProfileModel, PostListModel, PostListModel)) {
        var sectionModels: [OtherUserProfileSectionModel] = []
        
        sectionModels.append(OtherUserProfileSectionModel(title: nil, items: [.infoItem(value.0)]))
        
        if !value.1.data.isEmpty {
            otherUserProfileView.sections.insert(.product, at: 1)
            let productSection = OtherUserProfileSectionModel(title: "판매 중인 상품", items: value.1.data.map { .product($0) })
            sectionModels.append(productSection)
        } else {
            otherUserProfileView.sections.insert(.empty, at: 1)
            sectionModels.append(OtherUserProfileSectionModel(title: "판매 중인 상품", items: [.noProduct]))
        }
        
        if !value.2.data.isEmpty {
            otherUserProfileView.sections.insert(.post, at: 2)
            let postSection = OtherUserProfileSectionModel(title: "작성한 게시글", items: value.2.data.map { .post($0) })
            sectionModels.append(postSection)
        } else {
            otherUserProfileView.sections.insert(.empty, at: 2)
            sectionModels.append(OtherUserProfileSectionModel(title: "작성한 게시글", items: [.noPost]))
        }
        
        sections.onNext(sectionModels)
    }
    
    private func navigateToProductDetail(_ product: PostModel) {
        let vc = ProductDetailViewController()
        vc.postId = product.postId
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func navigateToPostDetail(_ post: PostModel) {
        let vc = PostDetailViewController()
        vc.postId = post.postId
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func navigateToChatRoom(_ userId: String) {
        let vc = ChatRoomViewController()
        vc.userId = userId
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func navigateToProductList(_ creator: CreatorModel) {
        let vc = ProfileProductListViewController()
        vc.userId = creator.userId
        vc.nickname = creator.nick
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func navigateToPostList(_ creator: CreatorModel) {
        let vc = ProfilePostListViewController()
        vc.userId = creator.userId
        vc.nickname = creator.nick
        navigationController?.pushViewController(vc, animated: true)
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
        }
        .disposed(by: disposeBag)
    }
}
