//
//  File.swift
//  
//
//  Created by Gus Adi on 20/10/23.
//

import Foundation

public extension NumberFormatter {
    public static var currency: NumberFormatter {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current.locale
        formatter.numberStyle = .currency
        return formatter
    }
}
