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
    
    func formatCurrency(_ amountString: String) -> String {
        guard let amount = Int(amountString) else { return "" }
        
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        
        if let formattedAmount = formatter.string(from: NSNumber(value: amount)) {
            return formattedAmount
        } else {
            return "\(amount)"
        }
    }
}
