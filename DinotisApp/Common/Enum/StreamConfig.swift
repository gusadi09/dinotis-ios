//
//  StreamConfig.swift
//  DinotisApp
//
//  Created by Garry on 04/08/22.
//

import SwiftUI

struct StreamConfig {
    enum Role: String, Identifiable {
        case host
        case speaker
        case viewer

        var id: String { rawValue }
    }

    let streamName: String
    let userIdentity: String
    var role: Role
}
