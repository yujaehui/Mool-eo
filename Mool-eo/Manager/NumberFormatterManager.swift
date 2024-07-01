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
    
    
    func formatCurrency(_ amount: Int) -> String {
        
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        
        if let formattedAmount = formatter.string(from: NSNumber(value: amount)) {
            return formattedAmount
        } else {
            return "\(amount)"
        }
    }
    
    func formatCurrencyString(_ amountString: String) -> String {
        guard let amount = Int(amountString) else { return "" }
        
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        
        if let formattedAmount = formatter.string(from: NSNumber(value: amount)) {
            return formattedAmount
        } else {
            return "\(amount)"
        }
    }
}
