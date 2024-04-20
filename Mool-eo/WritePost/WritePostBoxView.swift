//
//  WritePostBoxView.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/20/24.
//

import UIKit
import SnapKit

class WritePostBoxView: BaseView {
    let titleTextField: UITextField = {
        let textField = UITextField()
        textField.addLeftPadding()
        textField.font = FontStyle.titleBold
        textField.placeholder = "제목"
        return textField
    }()
    
    let lineView = LineView()
    
    let contentTextView: UITextView = {
        let textView = UITextView()
        textView.font = FontStyle.content
        textView.isScrollEnabled = false
        return textView
    }()
    
    let collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: configureCollectionViewLayout())
        collectionView.register(WritePostImageCollectionViewCell.self, forCellWithReuseIdentifier: WritePostImageCollectionViewCell.identifier)
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    let imageAddButton: UIButton = {
        let button = UIButton()
        button.configuration = .capsule("이미지 추가")
        return button
    }()
    
    override func configureHierarchy() {
        addSubview(titleTextField)
        addSubview(lineView)
        addSubview(contentTextView)
        addSubview(collectionView)
        addSubview(imageAddButton)
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
            make.height.equalTo(100)
        }
        
        imageAddButton.snp.makeConstraints { make in
            make.top.equalTo(collectionView.snp.bottom).offset(10)
            make.trailing.equalTo(safeAreaLayoutGuide).inset(20)
            make.bottom.equalTo(safeAreaLayoutGuide).inset(10)
            make.height.equalTo(40)
        }
    }
    
    private static func configureCollectionViewLayout() -> UICollectionViewLayout {
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
