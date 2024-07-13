//
//  WriteContentWithImageView.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 6/3/24.
//

import UIKit
import SnapKit

class WriteContentWithImageView: BaseView {
    let writeTextView: AutoResizableTextView = {
        let textView = AutoResizableTextView(maxHeight: 120)
        textView.font = FontStyle.content
        textView.backgroundColor = ColorStyle.subBackground
        textView.clipsToBounds = true
        textView.layer.cornerRadius = 10
        textView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 35)
        return textView
    }()
    
    let imageSelectButton: UIButton = {
        let button = UIButton()
        button.configuration = .image("photo.badge.plus")
        return button
    }()
    
    let textUploadButton: UIButton = {
        let button = UIButton()
        button.configuration = .image("paperplane")
        return button
    }()
    
    override func configureHierarchy() {
        addSubview(writeTextView)
        addSubview(imageSelectButton)
        addSubview(textUploadButton)
    }
    
    override func configureConstraints() {
        writeTextView.snp.makeConstraints { make in
            make.verticalEdges.equalTo(safeAreaLayoutGuide)
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(20)
        }
        
        imageSelectButton.snp.makeConstraints { make in
            make.trailing.equalTo(writeTextView.snp.trailing).inset(5)
            make.bottom.equalTo(writeTextView.snp.bottom).inset(5)
            make.size.equalTo(30)
        }
        
        textUploadButton.snp.makeConstraints { make in
            make.trailing.equalTo(writeTextView.snp.trailing).inset(5)
            make.bottom.equalTo(writeTextView.snp.bottom).inset(5)
            make.size.equalTo(25)
        }
    }
    
    func updateButtonVisibility(isTextEmpty: Bool) {
        let animationDuration = 0.3
        let rotationAngle: CGFloat = .pi / 2
        
        if isTextEmpty {
            UIView.animate(withDuration: animationDuration, animations: {
                self.textUploadButton.transform = CGAffineTransform(rotationAngle: rotationAngle).scaledBy(x: 0.1, y: 0.1)
                self.textUploadButton.alpha = 0.0
            }, completion: { _ in
                self.textUploadButton.isHidden = true
                self.textUploadButton.transform = .identity
            })
            self.imageSelectButton.transform = CGAffineTransform(rotationAngle: -rotationAngle).scaledBy(x: 0.1, y: 0.1)
            UIView.animate(withDuration: animationDuration, animations: {
                self.imageSelectButton.transform = .identity
                self.imageSelectButton.alpha = 1.0
            }, completion: { _ in
                self.imageSelectButton.isHidden = false
            })
        } else {
            UIView.animate(withDuration: animationDuration, animations: {
                self.imageSelectButton.transform = CGAffineTransform(rotationAngle: -rotationAngle).scaledBy(x: 0.1, y: 0.1)
                self.imageSelectButton.alpha = 0.0
            }, completion: { _ in
                self.imageSelectButton.isHidden = true
                self.imageSelectButton.transform = .identity
            })
            self.textUploadButton.transform = CGAffineTransform(rotationAngle: rotationAngle).scaledBy(x: 0.1, y: 0.1)
            UIView.animate(withDuration: animationDuration, animations: {
                self.textUploadButton.transform = .identity
                self.textUploadButton.alpha = 1.0
            }, completion: { _ in
                self.textUploadButton.isHidden = false
            })
        }
    }
}
