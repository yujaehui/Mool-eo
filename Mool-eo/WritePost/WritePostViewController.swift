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
    let writePostView = WritePostView()
    
    override func loadView() {
        self.view = writePostView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func bind() {
        let text = writePostView.contentTextView.rx.text.orEmpty.asObservable()
        let textViewBegin = writePostView.contentTextView.rx.didBeginEditing.asObservable()
        let textViewEnd = writePostView.contentTextView.rx.didEndEditing.asObservable()
        let input = WritePostViewModel.Input(text: text, textViewBegin: textViewBegin, textViewEnd: textViewEnd)
        
        let output = viewModel.transform(input: input)
        output.text.drive(writePostView.contentTextView.rx.text).disposed(by: disposeBag)
        output.textColorType.drive(with: self) { owner, value in
            owner.writePostView.contentTextView.textColor = value ? ColorStyle.mainText : ColorStyle.placeholder
        }.disposed(by: disposeBag)
    }
}
