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
        sections.bind(to: profileView.collectionView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
        
        let reload = reload
        let modelSelected = profileView.collectionView.rx.modelSelected(ProfileSectionItem.self).asObservable()
        let itemSelected = profileView.collectionView.rx.itemSelected.asObservable()
        let prefetch = profileView.collectionView.rx.prefetchItems.asObservable()
        let settingButtonTap = settingButtonTap
        let input = ProfileViewModel.Input(reload: reload, modelSelected: modelSelected, itemSelected: itemSelected, lastRow: lastRow, prefetch: prefetch, nextCursor: nextCursor, settingButtonTap: settingButtonTap)
        
        let output = viewModel.transform(input: input)
        output.result.bind(with: self) { owner, value in
            var sectionModels: [ProfileSectionModel] = []
            
            sectionModels.append(ProfileSectionModel(title: nil, items: [.infoItem(value.0)]))
            
            if !value.1.data.isEmpty {
                owner.profileView.sections.insert(.post, at: 1)
                let postSection = ProfileSectionModel(title: "작성한 게시글", items: value.1.data.map { .post($0) })
                sectionModels.append(postSection)
            } else {
                owner.profileView.sections.insert(.empty, at: 1)
                sectionModels.append(ProfileSectionModel(title: "작성한 게시글", items: [.noPost]))
            }
            
            if !value.2.data.isEmpty {
                owner.profileView.sections.insert(.product, at: 2)
                let productSection = ProfileSectionModel(title: "판매 중인 상품", items: value.2.data.map { .product($0) })
                sectionModels.append(productSection)
            } else {
                owner.profileView.sections.insert(.empty, at: 2)
                sectionModels.append(ProfileSectionModel(title: "판매 중인 상품", items: [.noProduct]))
            }
            
            owner.sections.onNext(sectionModels)
            
            guard value.2.nextCursor != "0" else { return }
            owner.nextCursor.onNext(value.2.nextCursor)
            
            let lastSection = owner.profileView.collectionView.numberOfSections - 1
            let lastRow = owner.profileView.collectionView.numberOfItems(inSection: lastSection) - 1
            owner.lastRow.onNext(lastRow)
            
        }.disposed(by: disposeBag)
        
        output.nextPostList.bind(with: self) { owner, value in
            owner.sections
                .take(1)
                .subscribe(onNext: { currentSections in
                    var updatedSections = currentSections
                    let updatedItems = updatedSections[2].items + value.data.map { .product($0) }
                    updatedSections[2] = ProfileSectionModel(title: "판매 중인 상품", items: updatedItems)
                    owner.sections.onNext(updatedSections)
                    owner.profileView.collectionView.reloadData()
                    guard value.nextCursor != "0" else { return }
                    owner.nextCursor.onNext(value.nextCursor)
                    let lastSection = owner.profileView.collectionView.numberOfSections - 1
                    let lastRow = owner.profileView.collectionView.numberOfItems(inSection: lastSection) - 1
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
    
    func configureDataSource() -> RxCollectionViewSectionedReloadDataSource<ProfileSectionModel> {
        let dataSource = RxCollectionViewSectionedReloadDataSource<ProfileSectionModel>(configureCell: { dataSource, collectionView, indexPath, item in
            switch item {
            case .infoItem(let info):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProfileCollectionViewCell.identifier, for: indexPath) as! ProfileCollectionViewCell
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
            case .post(let post):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostListCollectionViewCell.identifier, for: indexPath) as! PostListCollectionViewCell
                cell.configureCell(myPost: post)
                return cell
            case .product(let product):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProductPostListCollectionViewCell.identifier, for: indexPath) as! ProductPostListCollectionViewCell
                cell.configureCell(item: product)
                return cell
            case .noPost:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmptyCollectionViewCell.identifier, for: indexPath) as! EmptyCollectionViewCell
                cell.emptyLabel.text = "게시글이 없습니다"
                return cell
            case .noProduct:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmptyCollectionViewCell.identifier, for: indexPath) as! EmptyCollectionViewCell
                cell.emptyLabel.text = "상품이 없습니다"
                return cell
            }
        },configureSupplementaryView: { dataSource, collectionView, kind, indexPath in
            switch kind {
            case UICollectionView.elementKindSectionHeader:
                switch dataSource[indexPath.section].items[indexPath.item] {
                case .post(let post):
                    let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderCollectionReusableView.identifier, for: indexPath) as! HeaderCollectionReusableView
                    headerView.headerLabel.text = dataSource[indexPath.section].title
                    headerView.seeMoreButton.rx.tap.bind(with: self) { owner, _ in
                        let vc = ProfilePostListViewController()
                        vc.userId = UserDefaultsManager.userId!
                        vc.nickname = post.creator.nick
                        owner.navigationController?.pushViewController(vc, animated: true)
                    }.disposed(by: headerView.disposeBag)
                    return headerView
                default:
                    let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderCollectionReusableView.identifier, for: indexPath) as! HeaderCollectionReusableView
                    headerView.headerLabel.text = dataSource[indexPath.section].title
                    headerView.seeMoreButton.isHidden = true
                    return headerView
                }
            default:
                fatalError("Unexpected element kind")
            }
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
