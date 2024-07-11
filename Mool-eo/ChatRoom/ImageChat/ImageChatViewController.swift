//
//  ImageChatViewController.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 6/30/24.
//

import UIKit
import RxSwift
import RxCocoa

final class ImageChatViewController: BaseViewController {
    
    deinit { print("‼️ImageChatViewController Deinit‼️") }
    
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
        let input = ImageChatViewModel.Input(
            filesArray: Observable.just(filesArray),
            changePage: imageChatView.collectionView.rx.didEndDecelerating.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.filesArray.bind(to: imageChatView.collectionView.rx.items(cellIdentifier: ImageChatCollectionViewCell.identifier, cellType: ImageChatCollectionViewCell.self)) { (row, element, cell) in
            URLImageSettingManager.shared.setImageWithUrl(cell.chatImageView, urlString: element)
        }.disposed(by: disposeBag)
        
        output.pageCount.bind(to: imageChatView.pageControl.rx.numberOfPages).disposed(by: disposeBag)
        
        output.changePage
            .bind(with: self) { owner, _ in
            let pageWidth = owner.imageChatView.collectionView.frame.width
            let currentPage = Int(owner.imageChatView.collectionView.contentOffset.x / pageWidth)
            owner.imageChatView.pageControl.currentPage = currentPage
        }.disposed(by: disposeBag)
    }
}
