//
//  JoinSuccessView.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 7/7/24.
//

import UIKit
import SnapKit

final class JoinSuccessView: BaseView {
    let checkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "checkmark.circle.fill")
        imageView.tintColor = ColorStyle.point
        return imageView
    }()
    
    let joinSuccessLabel: CustomLabel = {
        let label = CustomLabel(type: .titleBold)
        label.text = "환영합니다!"
        return label
    }()
    
    let joinSuccessDescriptionLabel: CustomLabel = {
        let label = CustomLabel(type: .subContent)
        label.text = "이제부터 다양한 상품을 구매하고\n반려동물에 대해 궁금했던 점들을 물어보세요!"
        label.numberOfLines = 2
        label.textAlignment = .center
        return label
    }()
    
    let idStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .leading
        stackView.spacing = 15
        return stackView
    }()
    
    let idInfoLabel: CustomLabel = {
        let label = CustomLabel(type: .subContent)
        label.text = "아이디"
        return label
    }()
    
    let idLabel: CustomLabel = {
        let label = CustomLabel(type: .content)
        return label
    }()
    
    let nicknameStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .leading
        stackView.spacing = 15
        return stackView
    }()
    
    let nicknameInfoLabel: CustomLabel = {
        let label = CustomLabel(type: .subContent)
        label.text = "닉네임"
        return label
    }()
    
    let nicknameLabel: CustomLabel = {
        let label = CustomLabel(type: .content)
        return label
    }()
    
    let startButton: UIButton = {
        let button = UIButton()
        button.configuration = .check("로그인하기")
        return button
    }()
    
    override func configureHierarchy() {
        addSubview(checkImageView)
        addSubview(joinSuccessLabel)
        addSubview(joinSuccessDescriptionLabel)
        addSubview(idStackView)
        idStackView.addArrangedSubview(idInfoLabel)
        idStackView.addArrangedSubview(idLabel)
        addSubview(nicknameStackView)
        nicknameStackView.addArrangedSubview(nicknameInfoLabel)
        nicknameStackView.addArrangedSubview(nicknameLabel)
        addSubview(startButton)
    }
    
    override func configureConstraints() {
        checkImageView.snp.makeConstraints { make in
            make.top.equalTo(safeAreaLayoutGuide).inset(50)
            make.centerX.equalTo(safeAreaLayoutGuide)
            make.size.equalTo(80)
        }
        
        joinSuccessLabel.snp.makeConstraints { make in
            make.top.equalTo(checkImageView.snp.bottom).offset(20)
            make.centerX.equalTo(safeAreaLayoutGuide)
        }
        
        joinSuccessDescriptionLabel.snp.makeConstraints { make in
            make.top.equalTo(joinSuccessLabel.snp.bottom).offset(10)
            make.centerX.equalTo(safeAreaLayoutGuide)
        }
        
        idStackView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(20)
            make.bottom.equalTo(nicknameStackView.snp.top).offset(-20)
        }
        
        nicknameStackView.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(20)
            make.bottom.equalTo(startButton.snp.top).offset(-40)
        }
        
        startButton.snp.makeConstraints { make in
            make.horizontalEdges.equalTo(safeAreaLayoutGuide).inset(20)
            make.height.equalTo(40)
            make.bottom.equalTo(safeAreaLayoutGuide).inset(20)
        }
    }
}
