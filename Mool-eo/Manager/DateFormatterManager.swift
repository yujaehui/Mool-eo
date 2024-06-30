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
    
//    func formatDateToString(date: Date) -> String {
//        formatter.dateFormat = "yyyyMMdd"
//        formatter.locale = Locale(identifier: "ko_KR")
//        return formatter.string(from: date)
//    }
    
    func formatDateToString(dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        guard let date = inputFormatter.date(from: dateString) else { return "" }
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "yyyy.MM.dd"
        
        let formattedDateString = outputFormatter.string(from: date)
        return formattedDateString
    }
}
