//
//  UserProfileSectionModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 7/1/24.
//

import Foundation
import RxDataSources

enum UserProfileSectionItem {
    case infoItem(ProfileModel)
    case product(PostModel)
    case post(PostModel)
    case noProduct
    case noPost
    case more(MoreType)
}

struct UserProfileSectionModel {
    let title: String?
    var items: [UserProfileSectionItem]
}

extension UserProfileSectionModel: SectionModelType {
    typealias Item = UserProfileSectionItem
    
    init(original: UserProfileSectionModel, items: [UserProfileSectionItem]) {
        self = original
        self.items = items
    }
}
