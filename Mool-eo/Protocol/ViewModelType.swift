//
//  ViewModelType.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/10/24.
//

import Foundation
import RxSwift
import RxCocoa

protocol ViewModelType {
    var disposeBag: DisposeBag { get set }
    associatedtype Input
    associatedtype Output
    func transform(input: Input) -> Output
}
