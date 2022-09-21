//
//  BookingsDefaultRemoteDataSource.swift
//  DinotisApp
//
//  Created by Gus Adi on 11/03/22.
//

import Foundation
import Moya
import Combine

final class BookingsDefaultRemoteDataSource: BookingsRemoteDataSource {

	private let provider: MoyaProvider<BookingsTargetType>
	
	init(provider: MoyaProvider<BookingsTargetType> = .defaultProvider()) {
		self.provider = provider
	}
	
	func getBookingsById(bookingId: String) -> AnyPublisher<UserBooking, UnauthResponse> {
		provider.request(.getBookingsByBookingId(bookingId), model: UserBooking.self)
	}

	func getParticipant(by meetingId: String) -> AnyPublisher<Participant, UnauthResponse> {
		provider.request(.getParticipant(meetingId), model: Participant.self)
	}
}
