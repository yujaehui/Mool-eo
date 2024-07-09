//
//  ProfilePaymentListViewController.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 7/2/24.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class ProfilePaymentListViewController: BaseViewController {
    
    deinit { print("‼️ProfilePaymentListViewController Deinit‼️") }
    
    private let viewModel = ProfilePaymentListViewModel()
    private let profilePaymentView = ProfilePaymentListView()
    
    private let reload = BehaviorSubject<Void>(value: ())
    private var sections = BehaviorSubject<[PaymentListSectionModel]>(value: [])
    private lazy var dataSource = configureDataSource()
    
    override func loadView() {
        self.view = profilePaymentView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setNav() {
        navigationItem.title = "결제 내역"
    }
    
    override func configureView() {
        sections.bind(to: profilePaymentView.tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
    }
    
    override func bind() {
        let input = ProfilePaymentListViewModel.Input(reload: reload)
        let output = viewModel.transform(input: input)

        output.result.bind(with: self) { owner, value in
            owner.sections.onNext([PaymentListSectionModel(items: value.data)])
        }.disposed(by: disposeBag)
        
        output.networkFail.drive(with: self) { owner, _ in
            ToastManager.shared.showErrorToast(title: .networkFail, in: owner.profilePaymentView)
        }.disposed(by: disposeBag)
    }
    
    func configureDataSource() -> RxTableViewSectionedReloadDataSource<PaymentListSectionModel> {
        let dataSource = RxTableViewSectionedReloadDataSource<PaymentListSectionModel> { dataSource, tableView, indexPath, item in
            let cell = tableView.dequeueReusableCell(withIdentifier: ProfilePaymentListTableViewCell.identifier, for: indexPath) as! ProfilePaymentListTableViewCell
            cell.configureCell(item)
            return cell
        }
        return dataSource
    }
}


