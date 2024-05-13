//
//  SettingSectionModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/12/24.
//

import Foundation
import RxDataSources

enum SettingSectionItem {
    case info(ProfileModel)
    case management(String)
}

struct SettingSectionModel {
    var items: [SettingSectionItem]
}

extension SettingSectionModel: SectionModelType {
    typealias Item = SettingSectionItem
    
    init(original: SettingSectionModel, items: [SettingSectionItem]) {
        self = original
        self.items = items
    }
}
