//
//  ScheduleNegotiationChatViewModel.swift
//  DinotisApp
//
//  Created by Gus Adi on 05/10/22.
//

import Foundation

final class ScheduleNegotiationChatViewModel: ObservableObject {
	@Published var endChat: Date
    @Published var textMessage = ""
    
    var backToHome: () -> Void
    
    @Published var route: HomeRouting?

	@Published var token: String

	@Published var count: UInt = 30
    
    init(
		token: String,
		expireDate: Date,
        backToHome: @escaping (() -> Void)
    ) {
		self.token = token
		self.endChat = expireDate
        self.backToHome = backToHome
    }
}
