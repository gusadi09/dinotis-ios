//
//  File.swift
//  
//
//  Created by Gus Adi on 03/03/23.
//

import Foundation

public struct NotificationRequest: Codable {
    public var take: Int
    public var skip: Int
    public var type: String
    public var lang: String
    
    public init(take: Int, skip: Int, type: String, lang: String) {
        self.take = take
        self.skip = skip
        self.type = type
        self.lang = lang
    }
}
