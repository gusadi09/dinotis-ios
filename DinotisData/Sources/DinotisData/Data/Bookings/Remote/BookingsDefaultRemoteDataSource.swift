//
//  File.swift
//  
//
//  Created by Gus Adi on 01/02/23.
//

import Foundation

public protocol BookingsRemoteDataSource {
	func getBookingUser(with query: UserBookingQueryParam) async throws -> UserBookingsResponse
	func getBookingsById(bookingId: String) async throws -> UserBookingData
	func getParticipant(by meetingId: String) async throws -> ParticipantResponse
	func deleteBooking(by bookingId: String) async throws -> SuccessResponse
	func getTodayAgenda() async throws -> UserBookingsResponse
}
