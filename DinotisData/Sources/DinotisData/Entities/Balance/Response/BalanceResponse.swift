//
//  File.swift
//  
//
//  Created by Gus Adi on 09/03/23.
//

import Foundation

public struct CurrentBalanceResponse: Codable {
    public let current: String?
    
    public init(current: String?) {
        self.current = current
    }
}
