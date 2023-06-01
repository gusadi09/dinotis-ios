//
//  File.swift
//  
//
//  Created by Gus Adi on 30/05/23.
//

import Foundation

public enum VersionStatus: String, Codable {
    case RELEASE = "RELEASE"
    case MAINTENANCE = "MAINTENANCE"
    case OUTDATED = "OUTDATED"
}

public struct VersionResponse: Codable {
    public let id: Int?
    public let platform: String?
    public let version: String?
    public let status: VersionStatus?
    public let createdAt: Date?
    public let updatedAt: Date?
    
    public init(id: Int?, platform: String?, version: String?, status: VersionStatus?, createdAt: Date?, updatedAt: Date?) {
        self.id = id
        self.platform = platform
        self.version = version
        self.status = status
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
