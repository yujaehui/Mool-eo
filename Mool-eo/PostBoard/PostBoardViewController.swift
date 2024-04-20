//
//  PostBoardViewController.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/13/24.
//

import UIKit
import RxSwift
import RxCocoa
import Toast

enum PostBoardType: String, CaseIterable {
    case free = "자유게시판"
    case question = "질문게시판"
    case market = "장터게시판"
    case boast = "자랑게시판"
}

class PostBoardViewController: BaseViewController {
    let disposeBag = DisposeBag()
    let viewModel = PostBoardViewModel()
    let postBoardView = PostBoardView()
    
    override func loadView() {
        self.view = postBoardView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(#function)
        setNav()
    }
    
    override func bind() {
        let postBoardList = Observable.just(PostBoardType.allCases)
        let modelSelected = postBoardView.collectionView.rx.modelSelected(PostBoardType.self).asObservable()
        let itemSelected = postBoardView.collectionView.rx.itemSelected.asObservable()
        let input = PostBoardViewModel.Input(postBoardList: postBoardList, modelSelected: modelSelected, itemSelected: itemSelected)
        
        let output = viewModel.transform(input: input)
        output.postBoardList.bind(to: postBoardView.collectionView.rx.items(cellIdentifier: PostBoardCollectionViewCell.identifier, cellType: PostBoardCollectionViewCell.self)) { (row, element, cell) in
            cell.configureCell(element: element)
        }.disposed(by: disposeBag)
        
        output.postBoard.drive(with: self) { owner, value in
            let vc = PostListViewController()
            vc.postBoard = value
            owner.navigationController?.pushViewController(vc, animated: true)
        }.disposed(by: disposeBag)
    }
    
    func setNav() {
        let rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "person"), style: .plain, target: self, action: #selector(rightBarButtonItemClicked))
        navigationItem.rightBarButtonItem = rightBarButtonItem
    }
    
    @objc func rightBarButtonItemClicked() {
        navigationController?.pushViewController(ProfileViewController(), animated: true)
    }
}
