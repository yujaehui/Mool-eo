//
//  ChatDateTableViewCell.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 7/13/24.
//

import UIKit
import SnapKit

class ChatDateTableViewCell: BaseTableViewCell {
    let chatDateBackgroundView : UIView = {
        let view = UIView()
        view.backgroundColor = ColorStyle.subBackground
        view.clipsToBounds = true
        view.layer.cornerRadius = 10
        return view
    }()
    
    let chatDateLabel: CustomLabel = {
        let label = CustomLabel(type: .description)
        return label
    }()
    
    override func configureHierarchy() {
        contentView.addSubview(chatDateBackgroundView)
        chatDateBackgroundView.addSubview(chatDateLabel)
    }
    
    override func configureConstraints() {
        chatDateBackgroundView.snp.makeConstraints { make in
            make.verticalEdges.equalTo(contentView).inset(20)
            make.horizontalEdges.equalTo(contentView).inset(40)
            make.height.equalTo(25)
        }
        
        chatDateLabel.snp.makeConstraints { make in
            make.center.equalTo(chatDateBackgroundView)
        }
    }
    
    func configureCell(_ date: String) {
        chatDateLabel.text = date
    }
    
}
