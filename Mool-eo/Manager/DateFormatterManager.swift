//
//  DateFormatterManager.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/13/24.
//

import Foundation

class DateFormatterManager {
    static let shared = DateFormatterManager()
    private init() {}
    
    private let formatter = DateFormatter()
    
    func convertformatDateToString(date: Date) -> String {
        formatter.dateFormat = "yyyyMMdd"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
}
