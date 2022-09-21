//
//  BookingMeetingRepo.swift
//  DinotisApp
//
//  Created by Gus Adi on 07/10/21.
//

import Foundation

class BookingMeetingRepo {
	static let shared = BookingMeetingRepo()
	
	var meetingId = ""
	
	let baseUrl  = Configuration.shared.environment.baseURL
	
	var userBooking: URL {
		return URL(string: baseUrl + "/bookings")!
	}
	
	var bookingDetail: URL {
		return URL(string: baseUrl + "/bookings/\(meetingId)")!
	}
	
	var talentMeeting: URL {
		return URL(string: baseUrl + "/meetings?role=2&take=100")!
	}
	
	func detailMeeting(with meetingId: String) -> URL {
		return URL(string: baseUrl + "/meetings/\(meetingId)")!
	}
}
