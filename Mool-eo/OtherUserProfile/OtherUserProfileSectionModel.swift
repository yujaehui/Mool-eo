//
//  OtherUserProfileSectionModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/5/24.
//

import Foundation
import RxDataSources

enum OtherUserProfileSectionItem {
    case infoItem(OtherUserProfileModel)
    case product(PostModel)
    case post(PostModel)
    case noProduct
    case noPost
}

struct OtherUserProfileSectionModel {
    let title: String?
    var items: [OtherUserProfileSectionItem]
}

extension OtherUserProfileSectionModel: SectionModelType {
    typealias Item = OtherUserProfileSectionItem
    
    init(original: OtherUserProfileSectionModel, items: [OtherUserProfileSectionItem]) {
        self = original
        self.items = items
    }
}
