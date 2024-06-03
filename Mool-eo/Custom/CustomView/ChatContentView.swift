//
//  ChatContentView.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 6/3/24.
//

import UIKit
import SnapKit

class ChatContentView: BaseView {
    
    let chatLabel: CustomLabel = {
        let label = CustomLabel(type: .content)
        label.textAlignment = .right
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = ColorStyle.subBackground
        clipsToBounds = true
        layer.cornerRadius = 10
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configureHierarchy() {
        addSubview(chatLabel)
    }
    
    override func configureConstraints() {
        chatLabel.snp.makeConstraints { make in
            make.edges.equalTo(safeAreaLayoutGuide).inset(10)
        }
    }
}
