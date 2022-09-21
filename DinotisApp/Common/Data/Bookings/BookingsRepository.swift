//
//  BookingsRepository.swift
//  DinotisApp
//
//  Created by Gus Adi on 11/03/22.
//

import Foundation
import Combine

protocol BookingsRepository {
	func provideGetBookingsById(bookingId: String) -> AnyPublisher<UserBooking, UnauthResponse>
	func provideGetParticipant(by meetingId: String) -> AnyPublisher<Participant, UnauthResponse>
}
