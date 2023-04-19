//
//  File.swift
//  
//
//  Created by Gus Adi on 01/02/23.
//

import Foundation
import Moya

public final class BookingsDefaultRemoteDataSource: BookingsRemoteDataSource {

	private let provider: MoyaProvider<BookingsTargetType>

	public init(provider: MoyaProvider<BookingsTargetType> = .defaultProvider()) {
		self.provider = provider
	}

	public func getBookingUser(with query: UserBookingQueryParam) async throws -> UserBookingsResponse {
		try await provider.request(.getUserBooking(query), model: UserBookingsResponse.self)
	}

	public func getBookingsById(bookingId: String) async throws -> UserBookingData {
		try await provider.request(.getBookingsByBookingId(bookingId), model: UserBookingData.self)
	}

	public func getParticipant(by meetingId: String) async throws -> ParticipantResponse {
		try await provider.request(.getParticipant(meetingId), model: ParticipantResponse.self)
	}

	public func deleteBooking(by bookingId: String) async throws -> SuccessResponse {
		try await provider.request(.deleteBookings(bookingId), model: SuccessResponse.self)
	}

	public func getTodayAgenda() async throws -> UserBookingsResponse {
		try await provider.request(.getTodayAgenda, model: UserBookingsResponse.self)
	}
}
