//
//  MyProductViewController.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/27/24.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import Toast

class MyProductViewController: BaseViewController {
    weak var myScrollDelegate: MyScrollDelegate?
    
    deinit {
        print("‼️MyProductViewController Deinit‼️")
    }
    
    let viewModel = MyProductViewModel()
    let myProductView = MyProductView()
        
    var reload = BehaviorSubject(value: ())
    private let lastItem = PublishSubject<Int>()
    private let nextCursor = PublishSubject<String>()
    private var sections = BehaviorSubject<[MyProductSectionModel]>(value: [])
    private lazy var dataSource = configureDataSource()
    
    override func loadView() {
        self.view = myProductView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myProductView.collectionView.delegate = self
    }
    
    override func configureView() {
        sections.bind(to: myProductView.collectionView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
    }
    
    override func bind() {
        let prefetch = myProductView.collectionView.rx.prefetchItems.asObservable()
        let input = MyProductViewModel.Input(reload: reload, lastItem: lastItem, nextCursor: nextCursor, prefetch: prefetch)
        
        let output = viewModel.transform(input: input)
        
        output.result.bind(with: self) { owner, value in
            var sectionModels: [MyProductSectionModel] = []

            if !value.data.isEmpty {
                owner.myProductView.sections.insert(.product, at: 0)
                let productSection = MyProductSectionModel(items: value.data.map { .product($0) })
                sectionModels.append(productSection)
            } else {
                owner.myProductView.sections.insert(.empty, at: 0)
                sectionModels.append(MyProductSectionModel(items: [.noProduct]))
            }

            owner.sections.onNext(sectionModels)
            
            guard value.nextCursor != "0" else { return }
            owner.nextCursor.onNext(value.nextCursor)
            
            let lastSection = owner.myProductView.collectionView.numberOfSections - 1
            let lastItem = owner.myProductView.collectionView.numberOfItems(inSection: lastSection) - 1
            owner.lastItem.onNext(lastItem)

        }.disposed(by: disposeBag)
        
        output.networkFail.drive(with: self) { owner, _ in
            ToastManager.shared.showErrorToast(title: .networkFail, in: owner.myProductView)
        }.disposed(by: disposeBag)
        
        output.nextPostList.bind(with: self) { owner, value in
            owner.sections
                .take(1)
                .subscribe(onNext: { currentSections in
                    var updatedSections = currentSections
                    let updatedItems = updatedSections[0].items + value.data.map { .product($0) }
                    updatedSections[0] = MyProductSectionModel(items: updatedItems)
                    owner.sections.onNext(updatedSections)
                    owner.myProductView.collectionView.reloadData()
                    
                    guard value.nextCursor != "0" else { return }
                    owner.nextCursor.onNext(value.nextCursor)
                    
                    let lastSection = owner.myProductView.collectionView.numberOfSections - 1
                    let lastItem = owner.myProductView.collectionView.numberOfItems(inSection: lastSection) - 1
                    owner.lastItem.onNext(lastItem)
                })
                .disposed(by: owner.disposeBag)
        }.disposed(by: disposeBag)
    }
}

extension MyProductViewController {
    func configureDataSource() -> RxCollectionViewSectionedReloadDataSource<MyProductSectionModel> {
        let dataSource = RxCollectionViewSectionedReloadDataSource<MyProductSectionModel>(configureCell: { dataSource, collectionView, indexPath, item in
            switch item {
            case .product(let product):
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProductCollectionViewCell.identifier, for: indexPath) as! ProductCollectionViewCell
                cell.configureCell(item: product)
                return cell
            case .noProduct:
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmptyCollectionViewCell.identifier, for: indexPath) as! EmptyCollectionViewCell
                cell.emptyLabel.text = "상품이 없습니다"
                return cell
            }
        })
        return dataSource
    }
}

extension MyProductViewController: UICollectionViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        myScrollDelegate?.didScroll(scrollView: scrollView)
    }
}
