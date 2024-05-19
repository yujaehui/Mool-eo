//
//  ShoppingViewController.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/19/24.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import Toast

class ShoppingViewController: BaseViewController {
    
    deinit {
        print("‼️ShoppingViewController Deinit‼️")
    }
    
    let viewModel = ShoppingViewModel()
    let shoppingView = ShoppingView()
    
    var showProfileUpdateAlert: Bool = false
    
    var reload = BehaviorSubject(value: ())
    
    private var sections = BehaviorSubject<[ShoppingSectionModel]>(value: [])
    private lazy var dataSource = configureDataSource()
    
    override func loadView() {
        self.view = shoppingView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerObserver()
    }
    
    override func bind() {
        sections.bind(to: shoppingView.collectionView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
        
        let reload = reload
        let input = ShoppingViewModel.Input(reload: reload)
        
        let output = viewModel.transform(input: input)
        
        output.result.bind(with: self) { owner, value in
            var sectionModels: [ShoppingSectionModel] = []

            if !value.data.isEmpty {
                owner.shoppingView.sections.insert(.payment, at: 0)
                let paymentSection = ShoppingSectionModel(title: "결제 내역", items: value.data.map { .payment($0) })
                sectionModels.append(paymentSection)
            } else {
                owner.shoppingView.sections.insert(.empty, at: 0)
                sectionModels.append(ShoppingSectionModel(title: "결제 내역", items: [.noPayment]))
            }

            owner.sections.onNext(sectionModels)

        }.disposed(by: disposeBag)
        
        output.networkFail.drive(with: self) { owner, _ in
            ToastManager.shared.showErrorToast(title: .networkFail, in: owner.shoppingView)
        }.disposed(by: disposeBag)
    }
    
    func configureDataSource() -> RxCollectionViewSectionedReloadDataSource<ShoppingSectionModel> {
        let dataSource = RxCollectionViewSectionedReloadDataSource<ShoppingSectionModel>(configureCell: { dataSource, collectionView, indexPath, item in
            switch item {
            case .payment(let payment):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PaymentCollectionViewCell.identifier, for: indexPath) as! PaymentCollectionViewCell
                cell.configureCell(payment)
                return cell
            case .noPayment:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmptyCollectionViewCell.identifier, for: indexPath) as! EmptyCollectionViewCell
                cell.emptyLabel.text = "결제 내역이 없습니다"
                return cell
            }
        },configureSupplementaryView: { dataSource, collectionView, kind, indexPath in
            switch kind {
            case UICollectionView.elementKindSectionHeader:
                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderCollectionReusableView.identifier, for: indexPath) as! HeaderCollectionReusableView
                headerView.headerLabel.text = dataSource[indexPath.section].title
                headerView.seeMoreButton.isHidden = true
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
            NotificationCenter.default.rx.notification(Notification.Name(Noti.changePost.rawValue)),
            NotificationCenter.default.rx.notification(Notification.Name(Noti.changeProfile.rawValue))
        )
        .merge()
        .take(until: self.rx.deallocated)
        .subscribe(with: self) { owner, noti in
            owner.reload.onNext(())
            if (noti.object as? Bool) != nil {
                ToastManager.shared.showToast(title: "프로필이 수정되었습니다", in: owner.shoppingView)
            }
        }
        .disposed(by: disposeBag)
    }
}
