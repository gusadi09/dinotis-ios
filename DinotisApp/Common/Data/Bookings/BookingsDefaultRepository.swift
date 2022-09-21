//
//  BookingsDefaultRepository.swift
//  DinotisApp
//
//  Created by Gus Adi on 11/03/22.
//

import Foundation
import Combine

final class BookingsDefaultRepository: BookingsRepository {

	private let remoteDataSource: BookingsRemoteDataSource

	init(remoteDataSource: BookingsRemoteDataSource = BookingsDefaultRemoteDataSource()) {
		self.remoteDataSource = remoteDataSource
	}

	func provideGetBookingsById(bookingId: String) -> AnyPublisher<UserBooking, UnauthResponse> {
		remoteDataSource.getBookingsById(bookingId: bookingId)
	}

	func provideGetParticipant(by meetingId: String) -> AnyPublisher<Participant, UnauthResponse> {
		remoteDataSource.getParticipant(by: meetingId)
	}
}
