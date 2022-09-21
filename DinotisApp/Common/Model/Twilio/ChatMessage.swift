//
//  ChatMessage.swift
//  DinotisApp
//
//  Created by Garry on 05/08/22.
//

import TwilioConversationsClient

struct ChatMessage: Codable, Identifiable {
    let id: String
    let author: String
    let date: Date
    let body: String

    init?(message: TCHMessage) {
        guard
            let sid = message.sid,
            let date = message.dateCreatedAsDate,
            let author = message.author,
            let body = message.body
        else {
            return nil
        }

        id = sid
        self.author = author
        self.date = date
        self.body = body
    }
}

