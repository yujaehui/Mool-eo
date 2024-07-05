//
//  NumberFormatterManager.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/11/24.
//

import Foundation

class NumberFormatterManager {
    static let shared = NumberFormatterManager()
    private init() {}
    
    private let formatter = NumberFormatter()
    
    
    func formatCurrency(_ price: Int) -> String {
        
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        
        if let formattedAmount = formatter.string(from: NSNumber(value: price)) {
            return formattedAmount
        } else {
            return "\(price)"
        }
    }
    
    func formatCurrencyString(_ priceString: String) -> String {
        let cleanNumericString = priceString.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        if let number = Int(cleanNumericString) {
            formatter.numberStyle = .currency
            formatter.currencySymbol = "₩"
            formatter.maximumFractionDigits = 0
            if let formattedString = formatter.string(from: NSNumber(value: number)) {
                return formattedString
            }
        }
        return ""
    }
}
