//
//  File.swift
//  
//
//  Created by Irham Naufal on 13/09/23.
//

import Foundation

public extension String {
    func toDecimal() -> String {
        if let number = Int(self) {
            let formatter = NumberFormatter()
            formatter.groupingSeparator = "."
            formatter.numberStyle = .decimal
            formatter.locale = Locale.current.locale
            return formatter.string(from: NSNumber(value: number)).orEmpty()
        } else {
            return "0"
        }
    }
}
