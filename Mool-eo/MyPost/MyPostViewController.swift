//
//  MyPostViewController.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/27/24.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import Toast

class MyPostViewController: BaseViewController {
    
    weak var innerScrollDelegate: InnerScrollDelegate?
    private var dragDirection: DragDirection = .Up
    private var oldContentOffset = CGPoint.zero
    
    deinit {
        print("‼️MyPostViewController Deinit‼️")
    }
    
    let viewModel = MyPostViewModel()
    let myPostView = MyPostView()
        
    var reload = BehaviorSubject(value: ())
    private let lastItem = PublishSubject<Int>()
    private let nextCursor = PublishSubject<String>()
    private var sections = BehaviorSubject<[MyPostSectionModel]>(value: [])
    private lazy var dataSource = configureDataSource()
    
    override func loadView() {
        self.view = myPostView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myPostView.collectionView.delegate = self
    }
    
    override func configureView() {
        sections.bind(to: myPostView.collectionView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
    }
    
    override func bind() {
        let prefetch = myPostView.collectionView.rx.prefetchItems.asObservable()
        let input = MyPostViewModel.Input(reload: reload, lastItem: lastItem, nextCursor: nextCursor, prefetch: prefetch)
        
        let output = viewModel.transform(input: input)
        
        output.result.bind(with: self) { owner, value in
            var sectionModels: [MyPostSectionModel] = []

            if !value.data.isEmpty {
                owner.myPostView.sections.insert(.post, at: 0)
                let postSection = MyPostSectionModel(items: value.data.map { .post($0) })
                sectionModels.append(postSection)
            } else {
                owner.myPostView.sections.insert(.empty, at: 0)
                sectionModels.append(MyPostSectionModel(items: [.noPost]))
            }

            owner.sections.onNext(sectionModels)
            
            guard value.nextCursor != "0" else { return }
            owner.nextCursor.onNext(value.nextCursor)
            
            let lastSection = owner.myPostView.collectionView.numberOfSections - 1
            let lastItem = owner.myPostView.collectionView.numberOfItems(inSection: lastSection) - 1
            owner.lastItem.onNext(lastItem)

        }.disposed(by: disposeBag)
        
        output.networkFail.drive(with: self) { owner, _ in
            ToastManager.shared.showErrorToast(title: .networkFail, in: owner.myPostView)
        }.disposed(by: disposeBag)
        
        output.nextPostList.bind(with: self) { owner, value in
            owner.sections
                .take(1)
                .subscribe(onNext: { currentSections in
                    var updatedSections = currentSections
                    let updatedItems = updatedSections[0].items + value.data.map { .post($0) }
                    updatedSections[0] = MyPostSectionModel(items: updatedItems)
                    owner.sections.onNext(updatedSections)
                    owner.myPostView.collectionView.reloadData()
                    
                    guard value.nextCursor != "0" else { return }
                    owner.nextCursor.onNext(value.nextCursor)
                    
                    let lastSection = owner.myPostView.collectionView.numberOfSections - 1
                    let lastItem = owner.myPostView.collectionView.numberOfItems(inSection: lastSection) - 1
                    owner.lastItem.onNext(lastItem)
                })
                .disposed(by: owner.disposeBag)
        }.disposed(by: disposeBag)
    }
}

extension MyPostViewController {
    func configureDataSource() -> RxCollectionViewSectionedReloadDataSource<MyPostSectionModel> {
        let dataSource = RxCollectionViewSectionedReloadDataSource<MyPostSectionModel>(configureCell: { dataSource, collectionView, indexPath, item in
            switch item {
            case .post(let post):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostCollectionViewCell.identifier, for: indexPath) as! PostCollectionViewCell
                cell.configureCell(myPost: post)
                return cell
            case .noPost:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmptyCollectionViewCell.identifier, for: indexPath) as! EmptyCollectionViewCell
                cell.emptyLabel.text = "게시글이 없습니다"
                return cell
            }
        })
        return dataSource
    }
}

extension MyPostViewController: UICollectionViewDelegate {
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
