//
//  ProductPostDetailViewController.swift
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

class ProductPostDetailViewController: BaseViewController {
    
    deinit {
        print("‼️ProductPostDetailViewController Deinit‼️")
    }
    
    let viewModel = ProductPostDetailViewModel()
    let productPostDetailView = ProductPostDetailView()
    
    var postId: String = ""
    
    var reload = BehaviorSubject(value: ())
    var postModel = PublishSubject<PostModel>()
    
    private var sections = BehaviorSubject<[ProductPostDetailSectionModel]>(value: [])
    private lazy var dataSource = configureDataSource()
    
    override func loadView() {
        self.view = productPostDetailView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerObserver()
    }
    
    
    override func configureView() {
        sections.bind(to: productPostDetailView.tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
    }
    
    override func bind() {
        let postId = Observable.just(postId)
        let reload = reload
        let likeButtonTap = productPostDetailView.likeButton.rx.tap.asObservable()
        let buyButtonTap = productPostDetailView.buyButton.rx.tap.asObservable()
        let postModel = postModel
        let input = ProductPostDetailViewModel.Input(postId: postId, reload: reload, likeButtonTap: likeButtonTap, buyButtonTap: buyButtonTap, postModel: postModel)
        
        let output = viewModel.transform(input: input)
        
        output.postDetail.bind(with: self) { owner, value in
            owner.sections.onNext([ProductPostDetailSectionModel(title: nil, items: [.image(value)])]
                                  + [ProductPostDetailSectionModel(title: nil, items: [.info(value)])]
                                  + [ProductPostDetailSectionModel(title: "상세 정보", items: [.detail(value)])])
            owner.postModel.onNext(value)
            owner.productPostDetailView.likeButton.configuration = value.likesProduct.contains(UserDefaultsManager.userId!) ? .image("heart.fill") : .image("heart")
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
    }
    
    private func configureDataSource() -> RxTableViewSectionedReloadDataSource<ProductPostDetailSectionModel> {
        let dataSource = RxTableViewSectionedReloadDataSource<ProductPostDetailSectionModel> (configureCell : { dataSource, tableView, indexPath, item in
            switch item {
            case .image(let postModel):
                let cell = tableView.dequeueReusableCell(withIdentifier: ProductImageTableViewCell.identifier, for: indexPath) as! ProductImageTableViewCell
                cell.configureCell(postModel)
                return cell
            case .info(let postModel):
                let cell = tableView.dequeueReusableCell(withIdentifier: ProductInfoTableViewCell.identifier, for: indexPath) as! ProductInfoTableViewCell
                cell.configureCell(postModel)
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
                ToastManager.shared.showToast(title: "결제가 완료되었습니다", in: owner.productPostDetailView)
            }
        }
        .disposed(by: disposeBag)
    }
}
