//
//  WritePostViewController.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/10/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class WritePostViewController: BaseViewController {
    
    let disposeBag = DisposeBag()
    let viewModel = WritePostViewModel()
    
    let titleTextField: UITextField = {
       let textField = UITextField()
        textField.addLeftPadding()
        textField.font = FontStyle.titleBold
        textField.placeholder = "제목"
        return textField
    }()
    
    let lineView = LineView()
    
    lazy var contentTextView: UITextView = {
       let textView = UITextView()
        textView.font = FontStyle.content
        return textView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func bind() {
        let text = contentTextView.rx.text.orEmpty.asObservable()
        let textViewBegin = contentTextView.rx.didBeginEditing.asObservable()
        let textViewEnd = contentTextView.rx.didEndEditing.asObservable()
        let input = WritePostViewModel.Input(text: text, textViewBegin: textViewBegin, textViewEnd: textViewEnd)
        
        let output = viewModel.transform(input: input)
        output.text.drive(contentTextView.rx.text).disposed(by: disposeBag)
        output.textColorType.drive(with: self) { owner, value in
            owner.contentTextView.textColor = value ? ColorStyle.mainText : ColorStyle.placeholder
        }.disposed(by: disposeBag)
    }
    
    override func configureHierarchy() {
        view.addSubview(titleTextField)
        view.addSubview(lineView)
        view.addSubview(contentTextView)
    }
    
    override func configureConstraints() {
        titleTextField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.height.equalTo(44)
        }
        
        lineView.snp.makeConstraints { make in
            make.top.equalTo(titleTextField.snp.bottom)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.height.equalTo(1)
        }
        
        contentTextView.snp.makeConstraints { make in
            make.top.equalTo(lineView.snp.bottom).offset(10)
            make.horizontalEdges.equalTo(view.safeAreaLayoutGuide).inset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }
}
