//
//  File.swift
//  
//
//  Created by Gus Adi on 04/01/24.
//

import Foundation

public extension String {
    func isStringContainWhitespaceAndText() -> Bool {
        guard let array = self.compactMap({ $0 }) as? [Character] else { return false }
        
        guard let boolArray = array.compactMap({ !$0.isWhitespace }) as? [Bool] else { return false }
        
        return boolArray.contains(true)
    }
}
