//
//  File.swift
//  
//
//  Created by Gus Adi on 14/02/23.
//

import Foundation

public protocol GetParticipantsUseCase {
	func execute(by bookingId: String) async -> Result<ParticipantResponse, Error>
}
