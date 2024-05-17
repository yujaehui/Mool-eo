//
//  HashtagManager.swift
//  Mool-eo
//
//  Created by Jaehui Yu on 5/17/24.
//

import Foundation

final class HashtagManager {
    static let shared = HashtagManager()
    private init() {}
    
    func replaceSpacesWithUnderscore(_ text: String) -> String {
        return text.replacingOccurrences(of: " ", with: "_")
    }
    
    func convertToHashtagsAndUnderscore(_ text: String) -> String {
        let underscoreString = text.replacingOccurrences(of: " ", with: "_")
        return "#\(underscoreString)"
    }
    
    func removingTextAfterHash(_ text: String) -> String {
        if let hashIndex = text.firstIndex(of: "#") {
            return String(text[..<hashIndex])
        } else {
            return text
        }
    }
}
