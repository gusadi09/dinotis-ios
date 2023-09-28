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
            formatter.numberStyle = .decimal
            formatter.locale = Locale(identifier: "id_ID")
            return formatter.string(from: NSNumber(value: number)).orEmpty()
        } else {
            return self
        }
    }
}
