//
//  MyPaymentViewController.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/19/24.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import Toast

class MyPaymentViewController: BaseViewController {
    
    weak var innerScrollDelegate: InnerScrollDelegate?
    private var dragDirection: DragDirection = .Up
    private var oldContentOffset = CGPoint.zero
    
    deinit {
        print("‼️MyPaymentViewController Deinit‼️")
    }
    
    let viewModel = MyPaymentViewModel()
    let myPaymentView = MyPaymentView()
        
    var reload = BehaviorSubject(value: ())
    
    private var sections = BehaviorSubject<[MyPaymentSectionModel]>(value: [])
    private lazy var dataSource = configureDataSource()
    
    override func loadView() {
        self.view = myPaymentView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myPaymentView.collectionView.delegate = self
    }
    
    override func bind() {
        sections.bind(to: myPaymentView.collectionView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
        
        let reload = reload
        let input = MyPaymentViewModel.Input(reload: reload)
        
        let output = viewModel.transform(input: input)
        
        output.result.bind(with: self) { owner, value in
            var sectionModels: [MyPaymentSectionModel] = []

            if !value.data.isEmpty {
                owner.myPaymentView.sections.insert(.payment, at: 0)
                let paymentSection = MyPaymentSectionModel(items: value.data.map { .payment($0) })
                sectionModels.append(paymentSection)
            } else {
                owner.myPaymentView.sections.insert(.empty, at: 0)
                sectionModels.append(MyPaymentSectionModel(items: [.noPayment]))
            }

            owner.sections.onNext(sectionModels)

        }.disposed(by: disposeBag)
        
        output.networkFail.drive(with: self) { owner, _ in
            ToastManager.shared.showErrorToast(title: .networkFail, in: owner.myPaymentView)
        }.disposed(by: disposeBag)
    }
}

extension MyPaymentViewController {
    func configureDataSource() -> RxCollectionViewSectionedReloadDataSource<MyPaymentSectionModel> {
        let dataSource = RxCollectionViewSectionedReloadDataSource<MyPaymentSectionModel>(configureCell: { dataSource, collectionView, indexPath, item in
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
        })
        return dataSource
    }
}

extension MyPaymentViewController: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let delta = scrollView.contentOffset.y - oldContentOffset.y
        let topViewCurrentHeightConst = innerScrollDelegate?.currentHeaderHeight
        
        if let topViewUnwrappedHeight = topViewCurrentHeightConst {
            if delta > 0, topViewUnwrappedHeight > topViewHeightConstraintRange.lowerBound, scrollView.contentOffset.y > 0 {
                dragDirection = .Up
                innerScrollDelegate?.innerDidScroll(withDistance: delta)
                scrollView.contentOffset.y -= delta
            }
            
            if delta < 0, scrollView.contentOffset.y < 0 {
                dragDirection = .Down
                innerScrollDelegate?.innerDidScroll(withDistance: delta)
                scrollView.contentOffset.y -= delta
            }
        }
        
        oldContentOffset = scrollView.contentOffset
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y <= 0 {
            innerScrollDelegate?.innerScrollEnded(withScrollDirection: dragDirection)
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if decelerate == false && scrollView.contentOffset.y <= 0 {
            innerScrollDelegate?.innerScrollEnded(withScrollDirection: dragDirection)
        }
    }
}
