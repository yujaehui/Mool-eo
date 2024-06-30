//
//  ImageChatViewController.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 6/30/24.
//

import UIKit
import RxSwift
import RxCocoa

class ImageChatViewController: BaseViewController {
    
    deinit {
        print("‼️ImageChatViewController Deinit‼️")
    }
    
    let viewModel = ImageChatViewModel()
    let imageChatView = ImageChatView()
    
    var filesArray: [String] = []

    override func loadView() {
        self.view = imageChatView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func bind() {
        let filesArray = Observable.just(filesArray)
        let changePage = imageChatView.collectionView.rx.didEndDecelerating.asObservable()
        let input = ImageChatViewModel.Input(filesArray: filesArray, changePage: changePage)
        
        let output = viewModel.transform(input: input)
        
        output.filesArray.bind(to: imageChatView.collectionView.rx.items(cellIdentifier: ImageChatCollectionViewCell.identifier, cellType: ImageChatCollectionViewCell.self)) { (row, element, cell) in
            URLImageSettingManager.shared.setImageWithUrl(cell.chatImageView, urlString: element)
        }.disposed(by: disposeBag)
        
        output.filesArray
            .map { $0.count }
            .bind(to: imageChatView.pageControl.rx.numberOfPages)
            .disposed(by: disposeBag)
        
        output.changePage.bind(with: self) { owner, _ in
            let pageWidth = owner.imageChatView.collectionView.frame.width
            let currentPage = Int(owner.imageChatView.collectionView.contentOffset.x / pageWidth)
            owner.imageChatView.pageControl.currentPage = currentPage
        }.disposed(by: disposeBag)
    }
}
