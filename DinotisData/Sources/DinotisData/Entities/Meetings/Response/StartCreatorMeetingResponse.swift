//
//  File.swift
//  
//
//  Created by Gus Adi on 24/08/23.
//

import Foundation

public struct StartCreatorMeetingResponse: Codable {
    public let title: String?
    public let description: String?
    public let price: String?
    public let startAt: Date?
    public let endAt: Date?
    public let slots: Int?
    
    public init(title: String?, description: String?, price: String?, startAt: Date?, endAt: Date?, slots: Int?) {
        self.title = title
        self.description = description
        self.price = price
        self.startAt = startAt
        self.endAt = endAt
        self.slots = slots
    }
}
