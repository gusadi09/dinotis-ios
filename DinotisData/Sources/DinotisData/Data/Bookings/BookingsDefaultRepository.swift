//
//  File.swift
//  
//
//  Created by Gus Adi on 01/02/23.
//

import Foundation

public final class BookingsDefaultRepository: BookingsRepository {

	private let remoteDataSource: BookingsRemoteDataSource

	public init(remoteDataSource: BookingsRemoteDataSource = BookingsDefaultRemoteDataSource()) {
		self.remoteDataSource = remoteDataSource
	}

	public func provideGetBookingUser(with query: UserBookingQueryParam) async throws -> UserBookingsResponse {
		try await remoteDataSource.getBookingUser(with: query)
	}

	public func provideGetBookingsById(bookingId: String) async throws -> UserBookingData {
		try await remoteDataSource.getBookingsById(bookingId: bookingId)
	}

	public func provideGetParticipant(by meetingId: String) async throws -> ParticipantResponse {
		try await remoteDataSource.getParticipant(by: meetingId)
	}

	public func provideDeleteBooking(by bookingId: String) async throws -> SuccessResponse {
		try await remoteDataSource.deleteBooking(by: bookingId)
	}

	public func provideGetTodayAgenda() async throws -> UserBookingsResponse {
		try await remoteDataSource.getTodayAgenda()
	}
}
