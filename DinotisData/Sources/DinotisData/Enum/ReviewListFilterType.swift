//
//  File.swift
//  
//
//  Created by Gus Adi on 10/10/23.
//

import Foundation

public enum ReviewListFilterType {
    case asc
    case desc
    case highest
    case lowest
}

public extension ReviewListFilterType {
    var value: String {
        switch self {
        case .asc:
            return "asc"
        case .desc:
            return "desc"
        case .highest:
            return "highest"
        case .lowest:
            return "lowest"
        }
    }
}
