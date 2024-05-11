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
            owner.productPostDetailView.likeButton.configuration = value.scraps.contains(UserDefaultsManager.userId!) ? .pressed("heart.fill") : .pressed("heart")
        }.disposed(by: disposeBag)
        
        output.likeButtonTapResult.bind(with: self) { owner, value in
            owner.reload.onNext(())
        }.disposed(by: disposeBag)
        
        output.buyButtonTapResult.bind(with: self) { owner, postModel in
            let payment = IamportPayment(
                pg: PG.html5_inicis.makePgRawName(pgId: "INIpayTest"),
                merchant_uid: "ios_\(APIKey.secretKey)_\(Int(Date().timeIntervalSince1970))",
                amount: postModel.content1)
                .then {
                    $0.pay_method = PayMethod.card.rawValue
                    $0.name = postModel.title
                    $0.buyer_name = "유재희"
                    $0.app_scheme = "sesac"
                }
            let vc = ProductWebViewController()
            vc.payment = payment
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
}
