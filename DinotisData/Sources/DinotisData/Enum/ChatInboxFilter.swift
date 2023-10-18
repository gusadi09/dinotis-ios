//
//  File.swift
//  
//
//  Created by Gus Adi on 13/10/23.
//

import Foundation

public enum ChatInboxFilter {
    case asc
    case desc
}

public extension ChatInboxFilter {
    var value: String {
        switch self {
        case .asc:
            return "asc"
        case .desc:
            return "desc"
        }
    }
}
