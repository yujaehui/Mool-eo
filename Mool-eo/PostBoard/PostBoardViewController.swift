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

//enum PostBoardType: String, CaseIterable {
//    case free = "자유게시판"
//    case question = "질문게시판"
//    case share = "나눔게시판"
//    case boast = "자랑게시판"
//    
//    var image: UIImage {
//        switch self {
//        case .free: return UIImage(systemName: "face.smiling")!.withTintColor(ColorStyle.point)
//        case .question: return UIImage(systemName: "exclamationmark.questionmark")!.withTintColor(ColorStyle.point)
//        case .share: return UIImage(systemName: "bag")!.withTintColor(ColorStyle.point)
//        case .boast: return UIImage(systemName: "hand.thumbsup")!.withTintColor(ColorStyle.point)
//        }
//    }
//}
//
//class PostBoardViewController: BaseViewController {
//    
//    deinit {
//        print("‼️PostBoardViewController Deinit‼️")
//    }
//    
//    let viewModel = PostBoardViewModel()
//    let postBoardView = PostBoardView()
//    
//    override func loadView() {
//        self.view = postBoardView
//    }
//    
//    override func viewDidLoad() {
//        super.viewDidLoad()
//    }
//    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        tabBarController?.tabBar.isHidden = false
//    }
//    
//    override func setNav() {
//        navigationItem.title = "게시판"
//        navigationItem.backButtonTitle = ""
//        navigationController?.navigationBar.tintColor = ColorStyle.point
//    }
//    
//    override func bind() {
//        Observable.just(PostBoardType.allCases).bind(to: postBoardView.collectionView.rx.items(cellIdentifier: PostBoardCollectionViewCell.identifier, cellType: PostBoardCollectionViewCell.self)) { (row, element, cell) in
//            cell.configureCell(element: element)
//        }.disposed(by: disposeBag)
//        
//        let modelSelected = postBoardView.collectionView.rx.modelSelected(PostBoardType.self).asObservable()
//        let itemSelected = postBoardView.collectionView.rx.itemSelected.asObservable()
//        let input = PostBoardViewModel.Input(modelSelected: modelSelected, itemSelected: itemSelected)
//        
//        let output = viewModel.transform(input: input)
//        
//        // 특정 게시판 셀을 선택하면, 해당 게시판으로 이동
//        output.selectPostBoard.drive(with: self) { owner, value in
//            let vc = PostListViewController()
//            vc.postBoard = value
//            owner.navigationController?.pushViewController(vc, animated: true)
//        }.disposed(by: disposeBag)
//    }
//}
