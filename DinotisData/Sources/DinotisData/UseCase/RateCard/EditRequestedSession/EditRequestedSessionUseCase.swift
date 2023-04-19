//
//  File.swift
//  
//
//  Created by Gus Adi on 26/02/23.
//

import Foundation

public protocol EditRequestedSessionUseCase {
	func execute(by id: String, with body: EditRequestedSessionRequest) async -> Result<UserMeetingData, Error>
}
