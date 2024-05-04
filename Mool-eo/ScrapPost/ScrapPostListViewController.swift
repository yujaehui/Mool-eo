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

struct ScrapPostListSectionModel {
    var items: [PostModel]
}

extension ScrapPostListSectionModel: SectionModelType {
    typealias Item = PostModel
    
    init(original: ScrapPostListSectionModel, items: [PostModel]) {
        self = original
        self.items = items
    }
}

class ScrapPostListViewController: BaseViewController {
    
    let viewModel = ScrapPostListViewModel()
    let scrapPostListView = ScrapPostListView()
    
    var reload = BehaviorSubject(value: ())
    
    private var sections = BehaviorSubject<[ScrapPostListSectionModel]>(value: [])
    
    override func loadView() {
        self.view = scrapPostListView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func bind() {
        sections.bind(to: scrapPostListView.tableView.rx.items(dataSource: configureDataSource())).disposed(by: disposeBag)
        
        let reload = reload
        let modelSelected = scrapPostListView.tableView.rx.modelSelected(PostModel.self).asObservable()
        let itemSelected = scrapPostListView.tableView.rx.itemSelected.asObservable()
        let input = ScrapPostListViewModel.Input(reload: reload, modelSelected: modelSelected, itemSelected: itemSelected)
        
        let output = viewModel.transform(input: input)
        
        output.scrapPostList.bind(with: self) { owner, value in
            owner.sections.onNext([ScrapPostListSectionModel(items: value)])
        }.disposed(by: disposeBag)
        
        output.post.drive(with: self) { owner, value in
            let vc = PostDetailViewController()
            vc.delegate = owner
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
}

extension ScrapPostListViewController: PostDetailDelegate {
    func changePost(_ postBoard: PostBoardType) {
        scrapPostListView.tableView.reloadData()
        reload.onNext(())
    }
}
