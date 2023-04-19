//
//  File.swift
//  
//
//  Created by Gus Adi on 19/03/23.
//

import Foundation

public struct DateUtils {
    public static func dateFormatter(_ value: Date, forFormat format: DateFormat) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format.rawValue
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: value)
    }
    
    public static func dateFormatter(_ value: String, forFormat format: DateFormat) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = format.rawValue
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.date(from: value) ?? Date()
    }
}
