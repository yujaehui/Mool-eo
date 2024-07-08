//
//  WritePostContentView.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/20/24.
//

import UIKit
import SnapKit

final class WritePostContentView: BaseView {
    
    let imageAddButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.image = UIImage(systemName: "camera")
        button.tintColor = ColorStyle.point
        return button
    }()
        
    lazy var toolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.items = [imageAddButton]
        toolbar.sizeToFit()
        return toolbar
    }()
    
    lazy var titleTextField: UITextField = {
        let textField = UITextField()
        textField.addLeftPadding()
        textField.font = FontStyle.titleBold
        textField.placeholder = "제목"
        textField.inputAccessoryView = toolbar
        return textField
    }()
    
    let lineView = LineView()
    
    lazy var contentTextView: AutoResizableTextView = {
        let textView = AutoResizableTextView(maxHeight: nil)
        textView.font = FontStyle.content
        textView.isScrollEnabled = false
        textView.inputAccessoryView = toolbar
        return textView
    }()
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: configureCollectionViewLayout())
        collectionView.register(WritePostImageCollectionViewCell.self, forCellWithReuseIdentifier: WritePostImageCollectionViewCell.identifier)
        collectionView.register(WritePostImageEditCollectionViewCell.self, forCellWithReuseIdentifier: WritePostImageEditCollectionViewCell.identifier)
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    override func configureHierarchy() {
        addSubview(titleTextField)
        addSubview(lineView)
        addSubview(contentTextView)
        addSubview(collectionView)
    }
    
    override func configureConstraints() {
        
        titleTextField.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(20)
            make.height.equalTo(44)
        }
        
        lineView.snp.makeConstraints { make in
            make.top.equalTo(titleTextField.snp.bottom)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(20)
            make.height.equalTo(1)
        }
        
        contentTextView.snp.makeConstraints { make in
            make.top.equalTo(lineView.snp.bottom).offset(10)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(20)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(contentTextView.snp.bottom).offset(10)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide)
            make.bottom.equalTo(safeAreaLayoutGuide).inset(10)
            make.height.equalTo(120)
        }
    }
    
    private func configureCollectionViewLayout() -> UICollectionViewLayout {
        let layout = UICollectionViewFlowLayout()
        let spacing: CGFloat = 20
        let cellWidth = UIScreen.main.bounds.width - (spacing * 4)
        layout.itemSize = CGSize(width: cellWidth / 3, height: cellWidth / 3)
        layout.sectionInset = UIEdgeInsets(top: 0, left: spacing, bottom: spacing, right: spacing)
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        return layout
    }
}
