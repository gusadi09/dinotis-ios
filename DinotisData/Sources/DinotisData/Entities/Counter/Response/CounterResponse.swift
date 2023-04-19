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
    
    public init(unreadNotificationCount: Int?, todayAgendaCount: Int?) {
        self.unreadNotificationCount = unreadNotificationCount
        self.todayAgendaCount = todayAgendaCount
    }
}
