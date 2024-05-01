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
    
    override func loadView() {
        self.view = scrapPostListView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func bind() {
        let viewDidLoad = Observable.just(())
        let input = ScrapPostListViewModel.Input(viewDidLoad: viewDidLoad)
        
        let output = viewModel.transform(input: input)
        
        output.scrapPostList.bind(with: self) { owner, value in
            let sections: [ScrapPostListSectionModel] = [ScrapPostListSectionModel(items: value)]
            Observable.just(sections).bind(to: owner.scrapPostListView.tableView.rx.items(dataSource: owner.configureDataSource())).disposed(by: owner.disposeBag)
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
