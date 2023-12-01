//
//  PollRequest.swift
//
//
//  Created by Irham Naufal on 01/12/23.
//

import Foundation

public struct CreatePollRequest {
    public var question: String
    public var options: [PollOption]
    public var anonymous: Bool
    public var hideVotes: Bool
    
    public init(
        question: String = "",
        options: [PollOption] = [.init(), .init()],
        anonymous: Bool = true,
        hideVotes: Bool = true
    ) {
        self.question = question
        self.options = options
        self.anonymous = anonymous
        self.hideVotes = hideVotes
    }
}

public struct PollOption: Identifiable {
    public var id: UUID = .init()
    public var text: String
    
    public init(text: String = "") {
        self.text = text
    }
}
