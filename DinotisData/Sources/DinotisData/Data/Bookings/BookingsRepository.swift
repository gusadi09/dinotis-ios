//
//  File.swift
//  
//
//  Created by Gus Adi on 01/02/23.
//

import Foundation

public protocol BookingsRepository {
	func provideGetBookingUser(with query: UserBookingQueryParam) async throws -> UserBookingsResponse
	func provideGetBookingsById(bookingId: String) async throws -> UserBookingData
	func provideGetParticipant(by meetingId: String) async throws -> ParticipantResponse
	func provideDeleteBooking(by bookingId: String) async throws -> SuccessResponse
	func provideGetTodayAgenda() async throws -> UserBookingsResponse
}
