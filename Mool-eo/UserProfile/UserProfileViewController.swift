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

class UserProfileViewController: BaseViewController {
    
    deinit {
        print("‼️UserProfileViewController Deinit‼️")
    }
    
    let viewModel = UserProfileViewModel()
    let userProfileView = UserProfileView()
        
    var reload = BehaviorSubject(value: ())
    var profileImageData = PublishSubject<Data?>()
    var profileEditButtonTap = PublishSubject<Void>()
    
    private var sections = BehaviorSubject<[UserProfileSectionModel]>(value: [])
    
    private var nickname: String = ""
    
    override func loadView() {
        self.view = userProfileView
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
        sections.bind(to: userProfileView.collectionView.rx.items(dataSource: configureDataSource())).disposed(by: disposeBag)
        
        let modelSelected = userProfileView.collectionView.rx.modelSelected(UserProfileSectionItem.self).asObservable()
        let itemSelected =  userProfileView.collectionView.rx.itemSelected.asObservable()
        let input = UserProfileViewModel.Input(reload: reload, profileImageData: profileImageData, profileEditButtonTap: profileEditButtonTap, modelSelected: modelSelected, itemSelected: itemSelected)
        
        let output = viewModel.transform(input: input)
        output.result.bind(with: self) { owner, value in
            owner.nickname = value.0.nick
            
            var sectionModels: [UserProfileSectionModel] = []
            
            sectionModels.append(UserProfileSectionModel(title: nil, items: [.infoItem(value.0)]))
            
            if !value.1.data.isEmpty {
                owner.userProfileView.sections.insert(.product, at: 1)
                let productSection = UserProfileSectionModel(title: "판매 중인 상품", items: value.1.data.map { .product($0) })
                sectionModels.append(productSection)
            } else {
                owner.userProfileView.sections.insert(.empty, at: 1)
                sectionModels.append(UserProfileSectionModel(title: "판매 중인 상품", items: [.noProduct]))
            }
            
            if !value.2.data.isEmpty {
                owner.userProfileView.sections.insert(.post, at: 2)
                let postSection = UserProfileSectionModel(title: "작성한 게시글", items: value.2.data.map { .post($0) })
                sectionModels.append(postSection)
            } else {
                owner.userProfileView.sections.insert(.empty, at: 2)
                sectionModels.append(UserProfileSectionModel(title: "작성한 게시글", items: [.noPost]))
            }
            
            owner.userProfileView.sections.insert(.more, at: 3)
            let moreSection = UserProfileSectionModel(title: nil, items: MoreType.allCases.map { .more($0) })
            sectionModels.append(moreSection)
            
            owner.sections.onNext(sectionModels)
            
        }.disposed(by: disposeBag)
        
        output.profileEditButtonTap.bind(with: self) { owner, profile in
            let vc = ProfileEditViewController()
            vc.profileImageData = profile.1
            vc.profileImage = profile.0.profileImage
            vc.nickname = profile.0.nick
            vc.introduction = profile.0.introduction
            owner.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: disposeBag)
                
        output.productDetail.bind(with: self) { owner, value in
            let vc = ProductDetailViewController()
            vc.postId = value.postId
            vc.accessType = UserDefaultsManager.userId == value.creator.userId ? .me : .other
            vc.hidesBottomBarWhenPushed = true
            owner.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: disposeBag)
        
        output.postDetail.bind(with: self) { owner, value in
            let vc = PostDetailViewController()
            vc.postId = value.postId
            vc.accessType = UserDefaultsManager.userId! == value.creator.userId ? .me : .other
            owner.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: disposeBag)
        
        output.moreDetail.bind(with: self) { owner, value in
            switch value {
            case .like:
                let vc = LikeListViewController()
                owner.navigationController?.pushViewController(vc, animated: true)
            case .payment:
                let vc = ProfilePaymentListViewController()
                owner.navigationController?.pushViewController(vc, animated: true)
            }
        }.disposed(by: disposeBag)
                
        output.notFoundErr.drive(with: self) { owner, _ in
            ToastManager.shared.showErrorToast(title: .notFoundErrFollow, in: owner.userProfileView)
        }.disposed(by: disposeBag)
        
        output.networkFail.drive(with: self) { owner, _ in
            ToastManager.shared.showErrorToast(title: .networkFail, in: owner.userProfileView)
        }.disposed(by: disposeBag)
    }
    
    func configureDataSource() -> RxCollectionViewSectionedReloadDataSource<UserProfileSectionModel> {
        let dataSource = RxCollectionViewSectionedReloadDataSource<UserProfileSectionModel>(configureCell: { dataSource, collectionView, indexPath, item in
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
    
    // TODO: 프로필 수정 관련 로직 처리 필요
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
