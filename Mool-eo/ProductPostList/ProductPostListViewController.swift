//
//  ProductPostListViewController.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/10/24.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import Toast
import Kingfisher

enum ProductIdentifier: String {
    case market = "Mool-eo! Market"
}

class ProductPostListViewController: BaseViewController {
    
    deinit {
        print("‼️ProductPostListViewController Deinit‼️")
    }
    
    let viewModel = ProductPostListViewModel()
    let productPostListView = ProductPostListView()
    
    private let reload = BehaviorSubject<ProductIdentifier>(value: .market)
    private var sections = BehaviorSubject<[PostListSectionModel]>(value: [])
    private lazy var dataSource = configureDataSource()
    private let lastItem = PublishSubject<Int>()
    private let nextCursor = PublishSubject<String>()
    
    override func loadView() {
        self.view = productPostListView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        productPostListView.pinterestLayout.delegate = self
    }
    
    override func setNav() {
        navigationItem.title = "Mool-eo!"
        navigationItem.backButtonTitle = ""
        navigationController?.navigationBar.tintColor = ColorStyle.point
    }
    
    override func configureView() {
        sections.onNext([PostListSectionModel(items: [])]) // 초기에 빈 섹션 추가
        sections.bind(to: productPostListView.collectionView.rx.items(dataSource: dataSource)).disposed(by: disposeBag)
    }
    
    override func bind() {
        let reload = reload
        let postWriteButtonTap = productPostListView.productPostWriteButton.rx.tap.asObservable()
        let modelSelected = productPostListView.collectionView.rx.modelSelected(PostModel.self).asObservable()
        let itemSelected = productPostListView.collectionView.rx.itemSelected.asObservable()
        let prefetch = productPostListView.collectionView.rx.prefetchItems.asObservable()
        
        let input = ProductPostListViewModel.Input(reload: reload, postWriteButtonTap: postWriteButtonTap, modelSelected: modelSelected, itemSelected: itemSelected, lastItem: lastItem, nextCursor: nextCursor, prefetch: prefetch)
        
        let output = viewModel.transform(input: input)
        
        output.productPostList.bind(with: self) { owner, value in
            owner.sections.onNext([PostListSectionModel(items: value.data)])
            owner.productPostListView.collectionView.reloadData()
            guard value.nextCursor != "0" else { return }
            owner.nextCursor.onNext(value.nextCursor)
            let lastSection = owner.productPostListView.collectionView.numberOfSections - 1
            let lastItem = owner.productPostListView.collectionView.numberOfItems(inSection: lastSection) - 1
            owner.lastItem.onNext(lastItem)
        }.disposed(by: disposeBag)
        
        output.nextProductPostList.bind(with: self) { owner, value in
            owner.sections
                .take(1)
                .subscribe { currentSections in
                    var updatedSections = currentSections
                    updatedSections.append(PostListSectionModel(items: value.data))
                    owner.sections.onNext(updatedSections)
                    owner.productPostListView.collectionView.reloadData()
                    guard value.nextCursor != "0" else { return }
                    owner.nextCursor.onNext(value.nextCursor)
                }.disposed(by: owner.disposeBag)
        }.disposed(by: disposeBag)
        
        output.postWriteButtonTap.drive(with: self) { owner, _ in
            let vc = WriteProductPostViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            owner.present(nav, animated: true)
        }.disposed(by: disposeBag)
        
        // 특정 게시글 셀을 선택하면, 해당 게시글로 이동
        output.productPostId.drive(with: self) { owner, value in
            let vc = ProductPostDetailViewController()
            vc.postId = value
            vc.hidesBottomBarWhenPushed = true
            owner.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: disposeBag)
        
        output.networkFail.drive(with: self) { owner, _ in
            ToastManager.shared.showErrorToast(title: .networkFail, in: owner.productPostListView)
        }.disposed(by: disposeBag)
    }
    
    func configureDataSource() -> RxCollectionViewSectionedReloadDataSource<PostListSectionModel> {
        let dataSource = RxCollectionViewSectionedReloadDataSource<PostListSectionModel> { dataSource, collectionView, indexPath, item in
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ProductPostListCollectionViewCell.identifier, for: indexPath) as! ProductPostListCollectionViewCell
            cell.configureCell(item: item)
            return cell
        }
        return dataSource
    }
}

extension ProductPostListViewController: PinterestLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForPhotoAtIndexPath indexPath: IndexPath, completion: @escaping (CGFloat) -> Void) {
        var imageViewHeight: CGFloat = 180
        
        let item = dataSource[indexPath.section].items[indexPath.item]
        guard let imageUrl = URL(string: APIKey.baseURL.rawValue + item.files.first!) else {
            completion(imageViewHeight)
            return
        }
        
        let modifier = AnyModifier { request in
            var urlRequest = request
            urlRequest.headers[HTTPHeader.sesacKey.rawValue] = APIKey.secretKey.rawValue
            urlRequest.headers[HTTPHeader.authorization.rawValue] = UserDefaultsManager.accessToken!
            return urlRequest
        }
        
        KingfisherManager.shared.retrieveImage(with: imageUrl, options: [.requestModifier(modifier)]) { result in
            switch result {
            case .success(let value):
                let aspectRatio = value.image.size.width / value.image.size.height
                let cellWidth = (collectionView.bounds.width - 10) / 2
                imageViewHeight = cellWidth / aspectRatio
                completion(imageViewHeight + 60)
                collectionView.collectionViewLayout.invalidateLayout()
            case .failure(let error):
                print("Failed to load image: \(error)")
                completion(imageViewHeight)
            }
        }
    }
}
