//
//  ProductDetailViewController.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/10/24.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import iamport_ios
import WebKit
import Toast

final class ProductDetailViewController: BaseViewController {
    
    deinit { print("‼️ProductDetailViewController Deinit‼️") }
    
    private let viewModel = ProductDetailViewModel()
    private let productDetailView = ProductDetailView()
    
    private var reload = BehaviorSubject(value: ())
    
    private var sections = BehaviorSubject<[ProductDetailSectionModel]>(value: [])
    private lazy var dataSource = configureDataSource()
    
    private var deleteButtonTap = PublishSubject<Void>()
    
    var postId: String = ""
    var accessType: postDetailAccessType = .me
    
    override func loadView() {
        self.view = productDetailView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerObserver()
    }
    
    override func setNav() {
        var items: [UIAction] {
            let delete = UIAction(title: "삭제", image: UIImage(systemName: "trash"), attributes: .destructive, handler: { _ in
                self.deleteButtonTap.onNext(())
            })
            return [delete]
        }
        let menu = UIMenu(title: "", children: items)
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "ellipsis.circle"), menu: menu)
        navigationItem.rightBarButtonItem?.isHidden = accessType == .me ? false : true
    }
    
    override func configureView() {
        sections
            .bind(to: productDetailView.tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
    }
    
    override func bind() {
        let input = ProductDetailViewModel.Input(
            postId: postId,
            reload: reload,
            likeButtonTap: productDetailView.likeButton.rx.tap.asObservable(),
            buyButtonTap: productDetailView.buyButton.rx.tap.asObservable(),
            deleteButtonTap: deleteButtonTap
        )
        
        let output = viewModel.transform(input: input)
        
        output.productDetail.bind(with: self) { owner, value in
            owner.sections.onNext([ProductDetailSectionModel(title: nil, items: [.image(value)])]
                                  + [ProductDetailSectionModel(title: nil, items: [.info(value)])]
                                  + [ProductDetailSectionModel(title: "상세 정보", items: [.detail(value)])])
            owner.productDetailView.likeButton.configuration = value.likesProduct.contains(UserDefaultsManager.userId!) ? .heart("heart.fill") : .heart("heart")
        }.disposed(by: disposeBag)
        
        output.networkFail.drive(with: self) { owner, _ in
            ToastManager.shared.showErrorToast(title: .networkFail, in: owner.productDetailView)
        }.disposed(by: disposeBag)
        
        output.likeButtonTapResult.bind(with: self) { owner, value in
            NotificationCenter.default.post(name: Notification.Name(Noti.changeProduct.rawValue), object: nil)
            owner.reload.onNext(())
        }.disposed(by: disposeBag)
        
        output.buyButtonTapResult.bind(with: self) { owner, postModel in
            let vc = ProductWebViewController()
            vc.postModel = postModel
            owner.present(vc, animated: true)
        }.disposed(by: disposeBag)
        
        output.deleteButtonTapResult.bind(with: self) { owner, _ in
            NotificationCenter.default.post(name: Notification.Name(Noti.changeProduct.rawValue), object: nil)
            owner.navigationController?.popViewController(animated: true)
        }.disposed(by: disposeBag)
    }
    
    private func configureDataSource() -> RxTableViewSectionedReloadDataSource<ProductDetailSectionModel> {
        let dataSource = RxTableViewSectionedReloadDataSource<ProductDetailSectionModel> (configureCell : { dataSource, tableView, indexPath, item in
            switch item {
            case .image(let postModel):
                let cell = tableView.dequeueReusableCell(withIdentifier: ProductImageTableViewCell.identifier, for: indexPath) as! ProductImageTableViewCell
                cell.configureCell(postModel)
                return cell
            case .info(let postModel):
                let cell = tableView.dequeueReusableCell(withIdentifier: ProductInfoTableViewCell.identifier, for: indexPath) as! ProductInfoTableViewCell
                cell.configureCell(postModel)
                cell.profileStackView.rx.tapGesture()
                    .when(.recognized)
                    .bind(with: self) { owner, value in
                        if postModel.creator.userId != UserDefaultsManager.userId {
                            let vc = OtherUserProfileViewController()
                            vc.nickname = postModel.creator.nick
                            vc.userId = postModel.creator.userId
                            owner.navigationController?.pushViewController(vc, animated: true)
                        } else {
                            let vc = UserProfileViewController()
                            owner.navigationController?.pushViewController(vc, animated: true)
                        }
                    }.disposed(by: cell.disposeBag)
                return cell
            case .detail(let postModel):
                let cell = tableView.dequeueReusableCell(withIdentifier: ProductDetailTableViewCell.identifier, for: indexPath) as! ProductDetailTableViewCell
                cell.configureCell(postModel)
                return cell
            }
        }, titleForHeaderInSection: { dataSource, index in
            return dataSource.sectionModels[index].title
        })
        return dataSource
    }
    
    private func registerObserver() {
        Observable.of(
            NotificationCenter.default.rx.notification(Notification.Name(Noti.writeProduct.rawValue)),
            NotificationCenter.default.rx.notification(Notification.Name(Noti.payment.rawValue))
        )
        .merge()
        .take(until: self.rx.deallocated)
        .subscribe(with: self) { owner, noti in
            owner.reload.onNext(())
            if (noti.object as? Bool) != nil {
                ToastManager.shared.showToast(title: "결제가 완료되었습니다", in: owner.productDetailView)
            }
        }
        .disposed(by: disposeBag)
    }
}
