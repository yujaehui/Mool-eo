//
//  WriteProductPostContentView.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/10/24.
//

import UIKit
import SnapKit

class WriteProductPostContentView: BaseView {
    let imageAddButton: UIButton = {
        let button = UIButton()
        button.configuration = .imageAdd()
        return button
    }()
    
    let collectionViewLayout = {
        let layout = UICollectionViewCompositionalLayout { (sectionIndex, environment) -> NSCollectionLayoutSection? in
            ProductImageSection().layoutSection()
        }
        return layout
    }()
    
    lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        collectionView.register(WritePostImageCollectionViewCell.self, forCellWithReuseIdentifier: WritePostImageCollectionViewCell.identifier)
        collectionView.register(WritePostImageEditCollectionViewCell.self, forCellWithReuseIdentifier: WritePostImageEditCollectionViewCell.identifier)
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    let productNameView: ProductTextFieldView = {
        let view = ProductTextFieldView(frame: .zero, textFieldType: .productName)
        return view
    }()
    
    let priceView: ProductTextFieldView =  {
        let view = ProductTextFieldView(frame: .zero, textFieldType: .price)
        view.customTextField.keyboardType = .numberPad
        return view
    }()
    
    let detailLabel: CustomLabel = {
        let label = CustomLabel(type: .colorContentBold)
        label.text = "상세 정보"
        return label
    }()
    
    let detailTextView: AutoResizableTextView = {
        let textView = AutoResizableTextView(maxHeight: nil)
        textView.layer.borderColor = ColorStyle.placeholder.cgColor
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 10
        textView.font = FontStyle.content
        textView.isScrollEnabled = false
        return textView
    }()
    
    override func configureHierarchy() {
        addSubview(imageAddButton)
        addSubview(collectionView)
        addSubview(productNameView)
        addSubview(priceView)
        addSubview(detailLabel)
        addSubview(detailTextView)
    }
    
    override func configureConstraints() {
        imageAddButton.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).inset(10)
            make.leading.equalTo(safeAreaLayoutGuide).inset(20)
            make.size.equalTo(80)
        }
        
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).inset(10)
            make.leading.equalTo(imageAddButton.snp.trailing).offset(10)
            make.trailing.equalTo(safeAreaLayoutGuide).inset(20)
            make.height.equalTo(80)
        }
        
        productNameView.snp.makeConstraints { make in
            make.top.equalTo(imageAddButton.snp.bottom).offset(20)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(20)
        }
        
        priceView.snp.makeConstraints { make in
            make.top.equalTo(productNameView.snp.bottom).offset(20)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(20)
        }
        
        detailLabel.snp.makeConstraints { make in
            make.top.equalTo(priceView.snp.bottom).offset(20)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(20)
            make.height.equalTo(20)
        }
        
        detailTextView.snp.makeConstraints { make in
            make.top.equalTo(detailLabel.snp.bottom).offset(5)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(20)
            make.bottom.equalTo(safeAreaLayoutGuide).inset(10)
        }
    }
}
