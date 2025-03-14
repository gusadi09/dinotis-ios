//
//  File.swift
//  
//
//  Created by Gus Adi on 22/03/23.
//

import Foundation

public struct CounterResponse: Codable {
    public let unreadNotificationCount: Int?
    public let todayAgendaCount: Int?
    public let inboxCount: Int?
    
    public init(unreadNotificationCount: Int?, todayAgendaCount: Int?, inboxCount: Int?) {
        self.unreadNotificationCount = unreadNotificationCount
        self.todayAgendaCount = todayAgendaCount
        self.inboxCount = inboxCount
    }
}
