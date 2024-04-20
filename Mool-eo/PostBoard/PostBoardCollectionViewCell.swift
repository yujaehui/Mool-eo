//
//  PostBoardCollectionViewCell.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/13/24.
//

import UIKit
import SnapKit

class PostBoardCollectionViewCell: BaseCollectionViewCell {
    let backgrounView: UIView = {
        let view = UIView()
        view.backgroundColor = ColorStyle.subBackground
        view.clipsToBounds = true
        view.layer.cornerRadius = 20
        return view
    }()
    
    let titleLabel: CustomLabel = {
        let label = CustomLabel(type: .titleBold)
        return label
    }()
    
    let pointImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "star.fill")
        return imageView
    }()
    
    override func configureHierarchy() {
        contentView.addSubview(backgrounView)
        backgrounView.addSubview(titleLabel)
        backgrounView.addSubview(pointImageView)
    }
    
    override func configureConstraints() {
        backgrounView.snp.makeConstraints { make in
            make.edges.equalTo(contentView)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.leading.equalTo(backgrounView).inset(20)
        }
        
        pointImageView.snp.makeConstraints { make in
            make.bottom.trailing.equalTo(backgrounView).inset(20)
            make.size.equalTo(50)
        }
    }
    
    func configureCell(element: PostBoardType) {
        titleLabel.text = element.rawValue
    }
}
