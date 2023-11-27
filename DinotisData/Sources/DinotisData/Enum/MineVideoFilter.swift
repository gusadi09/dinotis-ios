//
//  File.swift
//  
//
//  Created by Gus Adi on 14/11/23.
//

import Foundation

public enum MineVideoSorting: String, Codable {
    case asc = "asc"
    case desc = "desc"
}

public enum MineVideoVideoType: String, Codable {
    case UPLOAD = "UPLOAD"
    case RECORD = "RECORD"
}

public enum MineVideoAudienceType: String, Codable {
    case PUBLIC = "PUBLIC"
    case SUBSCRIBER = "SUBSCRIBER"
}
