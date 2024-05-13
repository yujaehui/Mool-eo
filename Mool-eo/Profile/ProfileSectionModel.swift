//
//  ProfileSectionModel.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/5/24.
//

import Foundation
import RxDataSources

enum ProfileSectionItem {
    case infoItem(ProfileModel)
    case product(PostModel)
}

struct ProfileSectionModel {
    let title: String?
    var items: [ProfileSectionItem]
}

extension ProfileSectionModel: SectionModelType {
    typealias Item = ProfileSectionItem
    
    init(original: ProfileSectionModel, items: [ProfileSectionItem]) {
        self = original
        self.items = items
    }
}
