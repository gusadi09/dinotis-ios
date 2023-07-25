//
//  File.swift
//  
//
//  Created by Gus Adi on 24/07/23.
//

import Foundation

public struct DyteResponse: Codable {
    public let token: String?
    public let roomDocument: String?
    public let presetName: String?
    
    public enum CodingKeys: String, CodingKey {
        case token
        case roomDocument = "room_document"
        case presetName = "preset_name"
    }
    
    public init(token: String?, roomDocument: String?, presetName: String?) {
        self.token = token
        self.roomDocument = roomDocument
        self.presetName = presetName
    }
}
