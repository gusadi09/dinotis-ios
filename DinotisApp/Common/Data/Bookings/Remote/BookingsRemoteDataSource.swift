//
//  BookingsRemoteDataSource.swift
//  DinotisApp
//
//  Created by Gus Adi on 11/03/22.
//

import Foundation
import Combine

protocol BookingsRemoteDataSource {
	func getBookingsById(bookingId: String) -> AnyPublisher<UserBooking, UnauthResponse>
	func getParticipant(by meetingId: String) -> AnyPublisher<Participant, UnauthResponse>
}
