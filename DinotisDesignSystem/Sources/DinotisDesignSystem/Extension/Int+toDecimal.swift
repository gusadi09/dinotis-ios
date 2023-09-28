//
//  File.swift
//  
//
//  Created by Irham Naufal on 14/09/23.
//

import Foundation

public extension Int {
    func toDecimal() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale(identifier: "id_ID")
        return formatter.string(from: NSNumber(value: self)).orEmpty()
    }
}
