//
//  UserProfileViewController.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 7/1/24.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import Toast

final class UserProfileViewController: BaseViewController {
    
    deinit { print("‼️UserProfileViewController Deinit‼️") }
    
    let viewModel = UserProfileViewModel()
    let userProfileView = UserProfileView()
    
    private var reload = BehaviorSubject(value: ())
    private var profileImageData = PublishSubject<Data?>()
    private var profileEditButtonTap = PublishSubject<Void>()
    private var sections = BehaviorSubject<[UserProfileSectionModel]>(value: [])
    
    override func loadView() {
        self.view = userProfileView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerObserver()
    }
    
    override func setNav() {
        navigationItem.title = "프로필"
    }
    
    override func configureView() {
        sections.bind(to: userProfileView.collectionView.rx.items(dataSource: configureDataSource())).disposed(by: disposeBag)
    }
    
    override func bind() {
        let input = UserProfileViewModel.Input(
            reload: reload,
            profileImageData: profileImageData,
            profileEditButtonTap: profileEditButtonTap,
            modelSelected: userProfileView.collectionView.rx.modelSelected(UserProfileSectionItem.self).asObservable(),
            itemSelected: userProfileView.collectionView.rx.itemSelected.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.result.bind(with: self) { owner, value in
            owner.configureSections(value)
        }.disposed(by: disposeBag)
        
        output.profileEditButtonTap.bind(with: self) { owner, profile in
            owner.navigateToProfileEdit(profile)
        }.disposed(by: disposeBag)
        
        output.productDetail.bind(with: self) { owner, product in
            owner.navigateToProductDetail(product)
        }.disposed(by: disposeBag)
        
        output.postDetail.bind(with: self) { owner, post in
            owner.navigateToPostDetail(post)
        }.disposed(by: disposeBag)
        
        output.moreDetail.bind(with: self) { owner, more in
            owner.navigateToMoreDetail(more)
        }.disposed(by: disposeBag)
        
        output.networkFail.drive(with: self) { owner, _ in
            ToastManager.shared.showErrorToast(title: .networkFail, in: owner.userProfileView)
        }.disposed(by: disposeBag)
    }
    
    private func configureDataSource() -> RxCollectionViewSectionedReloadDataSource<UserProfileSectionModel> {
        return RxCollectionViewSectionedReloadDataSource<UserProfileSectionModel>(
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
    
    private func configureCell(_ dataSource: CollectionViewSectionedDataSource<UserProfileSectionModel>, _ collectionView: UICollectionView, _ indexPath: IndexPath, _ item: UserProfileSectionItem) -> UICollectionViewCell {
            switch item {
            case .infoItem(let info):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserProfileInfoCollectionViewCell.identifier, for: indexPath) as! UserProfileInfoCollectionViewCell
                cell.configureCell(info)
                cell.profileEditButton.rx.tap.bind(with: self) { owner, _ in
                    owner.profileImageData.onNext(cell.profileImageView.image?.pngData())
                    owner.profileEditButtonTap.onNext(())
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
            case .more(let more):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: UserProfileMoreCollectionViewCell.identifier, for: indexPath) as! UserProfileMoreCollectionViewCell
                cell.configureCell(more)
                return cell
            }
        }
    
    private func configureSupplementaryView(_ dataSource: CollectionViewSectionedDataSource<UserProfileSectionModel>, _ collectionView: UICollectionView, _ kind: String, _ indexPath: IndexPath) -> UICollectionReusableView {
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
    
    private func setupHeaderButton(for headerView: HeaderCollectionReusableView, with item: UserProfileSectionItem) {
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
    
    private func configureSections(_ value: (ProfileModel, PostListModel, PostListModel)) {
        var sectionModels: [UserProfileSectionModel] = []
        
        sectionModels.append(UserProfileSectionModel(title: nil, items: [.infoItem(value.0)]))
        
        if !value.1.data.isEmpty {
            userProfileView.sections.insert(.product, at: 1)
            let productSection = UserProfileSectionModel(title: "판매 중인 상품", items: value.1.data.map { .product($0) })
            sectionModels.append(productSection)
        } else {
            userProfileView.sections.insert(.empty, at: 1)
            sectionModels.append(UserProfileSectionModel(title: "판매 중인 상품", items: [.noProduct]))
        }
        
        if !value.2.data.isEmpty {
            userProfileView.sections.insert(.post, at: 2)
            let postSection = UserProfileSectionModel(title: "작성한 게시글", items: value.2.data.map { .post($0) })
            sectionModels.append(postSection)
        } else {
            userProfileView.sections.insert(.empty, at: 2)
            sectionModels.append(UserProfileSectionModel(title: "작성한 게시글", items: [.noPost]))
        }
        
        userProfileView.sections.insert(.more, at: 3)
        let moreSection = UserProfileSectionModel(title: nil, items: MoreType.allCases.map { .more($0) })
        sectionModels.append(moreSection)
        
        sections.onNext(sectionModels)
    }
    
    private func navigateToProfileEdit(_ profile: (ProfileModel, Data?)) {
        let vc = ProfileEditViewController()
        vc.nickname = profile.0.nick
        vc.profileImage = profile.0.profileImage
        vc.profileImageData = profile.1
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func navigateToProductDetail(_ product: PostModel) {
        let vc = ProductDetailViewController()
        vc.postId = product.postId
        vc.accessType = UserDefaultsManager.userId == product.creator.userId ? .me : .other
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func navigateToPostDetail(_ post: PostModel) {
        let vc = PostDetailViewController()
        vc.postId = post.postId
        vc.accessType = UserDefaultsManager.userId! == post.creator.userId ? .me : .other
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func navigateToMoreDetail(_ moreType: MoreType) {
        switch moreType {
        case .like:
            let vc = LikeListViewController()
            navigationController?.pushViewController(vc, animated: true)
        case .payment:
            let vc = ProfilePaymentListViewController()
            navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    private func navigateToProductList(_ creator: Creator) {
        let vc = ProfileProductListViewController()
        vc.userId = creator.userId
        vc.nickname = creator.nick
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func navigateToPostList(_ creator: Creator) {
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
            if (noti.object as? Bool) != nil {
                ToastManager.shared.showToast(title: "프로필이 변경되었습니다", in: owner.userProfileView)
            }
        }
        .disposed(by: disposeBag)
    }
}
