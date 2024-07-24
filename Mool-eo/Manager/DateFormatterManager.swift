//
//  DateFormatterManager.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 4/13/24.
//

import Foundation

final class DateFormatterManager {
    static let shared = DateFormatterManager()
    private init() {}
    
    private let formatter = DateFormatter()
    
    func formatDateToString(dateString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        guard let date = inputFormatter.date(from: dateString) else { return "" }
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "yyyy.MM.dd"
        
        let formattedDateString = outputFormatter.string(from: date)
        return formattedDateString
    }
    
    func formatTimeToString(timeString: String) -> String {
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        guard let date = inputFormatter.date(from: timeString) else { return "" }
        
        let outputFormatter = DateFormatter()
        outputFormatter.dateFormat = "a h:mm"
        outputFormatter.amSymbol = "오전"
        outputFormatter.pmSymbol = "오후"
        
        let formattedDateString = outputFormatter.string(from: date)
        return formattedDateString
    }
}
