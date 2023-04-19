//
//  File.swift
//  
//
//  Created by Gus Adi on 14/03/23.
//

import Foundation

public struct ReportRequest: Codable {
    public var identity: String
    public var reasons: String
    public var notes: String
    public var room: String
    public var userId: String
    public var meetingId: String
    
    public init(identity: String, reasons: String, notes: String, room: String, userId: String, meetingId: String) {
        self.identity = identity
        self.reasons = reasons
        self.notes = notes
        self.room = room
        self.userId = userId
        self.meetingId = meetingId
    }
}
