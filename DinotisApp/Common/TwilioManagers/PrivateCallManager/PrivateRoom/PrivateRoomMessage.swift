//
//  PrivateRoomMessage.swift
//  DinotisApp
//
//  Created by Garry on 08/09/22.
//

import Foundation

struct PrivateRoomMessage: Codable {
    enum MessageType: String, Codable {
        case mute
        case qna
        case remove
        case spotlight
    }
    
    let messageType: MessageType
    let toParticipantIdentity: String
}
