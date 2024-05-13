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

class SettingViewController: BaseViewController {
    
    let viewModel = SettingViewModel()
    let settingView = SettingView()
    
    private var sections = BehaviorSubject<[SettingSectionModel]>(value: [])
    private lazy var dataSource = configureDataSource()
    
    var reload = BehaviorSubject(value: ())
    
    override func loadView() {
        self.view = settingView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setNav() {
        navigationItem.title = "설정"
        navigationItem.backButtonTitle = ""
        navigationController?.navigationBar.tintColor = ColorStyle.point
    }
    
    override func configureView() {
        sections.bind(to: settingView.tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
    }
    
    override func bind() {
        let reload = reload
        let modelSelected = settingView.tableView.rx.modelSelected(SettingSectionItem.self).asObservable()
        let itemSelected = settingView.tableView.rx.itemSelected.asObservable()
        let input = SettingViewModel.Input(reload: reload, modelSelected: modelSelected, itemSelected: itemSelected)
        
        let output = viewModel.transform(input: input)
        
        output.profile.bind(with: self) { owner, profile in
            owner.sections.onNext([SettingSectionModel(items: [.info(profile)])]
                                  + [SettingSectionModel(items: [.management("탈퇴")])])
        }.disposed(by: disposeBag)
        
        output.withdrawSuccessTrigger.bind(with: self) { owner, _ in
            let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene
            let sceneDelegate = windowScene?.delegate as? SceneDelegate
            sceneDelegate?.window?.rootViewController = UINavigationController(rootViewController: LoginViewController())
            sceneDelegate?.window?.makeKeyAndVisible()
        }.disposed(by: disposeBag)
    }
    
    func configureDataSource() -> RxTableViewSectionedReloadDataSource<SettingSectionModel> {
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
