//
//  ScrapPostListViewController.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/1/24.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

class ScrapPostListViewController: BaseViewController {
    
    deinit {
        print("‼️ScrapPostListViewController Deinit‼️")
    }
    
    let viewModel = ScrapPostListViewModel()
    let scrapPostListView = ScrapPostListView()
    
    var reload = BehaviorSubject(value: ())
    
    private var sections = BehaviorSubject<[ScrapPostListSectionModel]>(value: [])
    private lazy var dataSource = configureDataSource()
    
    private let lastRow = PublishSubject<Int>()
    private let nextCursor = PublishSubject<String>()
    
    override func loadView() {
        self.view = scrapPostListView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        registerObserver()
    }
    
    override func bind() {
        sections.bind(to: scrapPostListView.tableView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
        
        let reload = reload
        let modelSelected = scrapPostListView.tableView.rx.modelSelected(PostModel.self).asObservable()
        let itemSelected = scrapPostListView.tableView.rx.itemSelected.asObservable()
        let prefetch = scrapPostListView.tableView.rx.prefetchRows.asObservable()
        let input = ScrapPostListViewModel.Input(reload: reload, modelSelected: modelSelected, itemSelected: itemSelected, lastRow: lastRow, prefetch: prefetch, nextCursor: nextCursor)
        
        let output = viewModel.transform(input: input)
        
        output.scrapPostList.bind(with: self) { owner, value in
            owner.sections.onNext([ScrapPostListSectionModel(items: value.data)])
            guard value.nextCursor != "0" else { return }
            owner.nextCursor.onNext(value.nextCursor)
            let lastSection = owner.scrapPostListView.tableView.numberOfSections - 1
            let lastRow = owner.scrapPostListView.tableView.numberOfRows(inSection: lastSection) - 1
            owner.lastRow.onNext(lastRow)
        }.disposed(by: disposeBag)
        
        output.nextScrapPostList.bind(with: self) { owner, value in
            owner.sections
                .take(1)
                .subscribe(onNext: { currentSections in
                    var updatedSections = currentSections
                    updatedSections.append(ScrapPostListSectionModel(items: value.data))
                    owner.sections.onNext(updatedSections)
                    owner.scrapPostListView.tableView.reloadData()
                    guard value.nextCursor != "0" else { return }
                    owner.nextCursor.onNext(value.nextCursor)
                })
                .disposed(by: owner.disposeBag)
        }.disposed(by: disposeBag)
        
        output.post.drive(with: self) { owner, value in
            let vc = PostDetailViewController()
            vc.postId = value
            owner.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: disposeBag)
    }
    
    func configureDataSource() -> RxTableViewSectionedReloadDataSource<ScrapPostListSectionModel> {
        let dataSource = RxTableViewSectionedReloadDataSource<ScrapPostListSectionModel> { dataSource, tableView, indexPath, item in
            if item.files.isEmpty { // 이미지가 없는 게시글일 경우
                let cell = tableView.dequeueReusableCell(withIdentifier: PostListWithoutImageTableViewCell.identifier, for: indexPath) as! PostListWithoutImageTableViewCell
                cell.configureCell(item: item)
                return cell
            } else { // 이미지가 있는 게시글일 경우
                let cell = tableView.dequeueReusableCell(withIdentifier: PostListTableViewCell.identifier, for: indexPath) as! PostListTableViewCell
                cell.configureCell(item: item)
                return cell
            }
        }
        return dataSource
    }
    
    private func registerObserver() {
        NotificationCenter.default.rx.notification(Notification.Name(Noti.changePost.rawValue))
            .take(until: self.rx.deallocated)
            .subscribe(with: self) { owner, _ in
                owner.reload.onNext(())
            }
            .disposed(by: disposeBag)
    }
}
