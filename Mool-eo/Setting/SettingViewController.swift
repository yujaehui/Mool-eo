//
//  SettingViewController.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/12/24.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

final class SettingViewController: BaseViewController {
    
    let viewModel = SettingViewModel()
    let settingView = SettingView()
    
    private var reload = BehaviorSubject(value: ())
    private var sections = BehaviorSubject<[SettingSectionModel]>(value: [])
    private var withdrawButtonTap = PublishSubject<Void>()
    
    override func loadView() {
        self.view = settingView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setNav() {
        super.setNav()
        navigationItem.title = "설정"
    }
    
    override func configureView() {
        sections.bind(to: settingView.tableView.rx.items(dataSource: configureDataSource())).disposed(by: disposeBag)
    }
    
    override func bind() {
        let input = SettingViewModel.Input(
            reload: reload,
            modelSelected: settingView.tableView.rx.modelSelected(SettingSectionItem.self).asObservable(),
            itemSelected: settingView.tableView.rx.itemSelected.asObservable(),
            withdrawButtonTap: withdrawButtonTap
        )
        
        let output = viewModel.transform(input: input)
        
        output.profile.bind(with: self) { owner, profile in
            owner.sections.onNext([SettingSectionModel(items: [.info(profile)])]
                                  + [SettingSectionModel(items: [.management("탈퇴")])])
        }.disposed(by: disposeBag)
        
        output.withdrawCheck.bind(with: self) { owner, _ in
            let alert = AlertManager.shared.showWithdrawAlert { _ in
                owner.withdrawButtonTap.onNext(())
            }
            owner.present(alert, animated: true)
        }.disposed(by: disposeBag)
        
        output.withdrawSuccessTrigger.bind(with: self) { owner, _ in
            TransitionManager.shared.setInitialViewController(LoginViewController(), navigation: true)
        }.disposed(by: disposeBag)
        
        output.networkFail.drive(with: self) { owner, _ in
            ToastManager.shared.showErrorToast(title: .networkFail, in: owner.settingView)
        }.disposed(by: disposeBag)
    }
    
    private func configureDataSource() -> RxTableViewSectionedReloadDataSource<SettingSectionModel> {
        let dataSource = RxTableViewSectionedReloadDataSource<SettingSectionModel>(configureCell: { dataSource, tableView, indexPath, item in
            switch item {
            case .info(let info):
                let cell = tableView.dequeueReusableCell(withIdentifier: SettingInfoTableViewCell.identifier, for: indexPath) as! SettingInfoTableViewCell
                cell.selectionStyle = .none
                cell.configureCell(info)
                return cell
            case .management(let management):
                let cell = tableView.dequeueReusableCell(withIdentifier: SettingManagementTableViewCell.identifier, for: indexPath) as! SettingManagementTableViewCell
                cell.selectionStyle = .none
                cell.configureCell(management)
                return cell
            }
        })
        return dataSource
    }
}
