//
//  File.swift
//  
//
//  Created by Gus Adi on 01/02/23.
//

import Foundation
import Moya

public enum BookingsTargetType {
	case getUserBooking(UserBookingQueryParam)
	case getBookingsByBookingId(String)
	case deleteBookings(String)
	case getParticipant(String)
	case getTodayAgenda
}

extension BookingsTargetType: DinotisTargetType, AccessTokenAuthorizable {
	var parameters: [String : Any] {
		switch self {
		case .getBookingsByBookingId:
			return [:]
		case .getParticipant:
			return [:]
		case .getUserBooking(let query):
			return query.toJSON()
		case .deleteBookings(_):
			return [:]
		case .getTodayAgenda:
			return [:]
		}
	}

	public var headers: [String : String]? {
		return [:]
	}

	public var authorizationType: AuthorizationType? {
		return .bearer
	}

	var parameterEncoding: Moya.ParameterEncoding {
		switch self {
		case .getBookingsByBookingId:
			return URLEncoding.default
		case .getParticipant:
			return URLEncoding.default
		case .getUserBooking:
			return URLEncoding.default
		case .deleteBookings(_):
			return URLEncoding.default
		case .getTodayAgenda:
			return URLEncoding.queryString
		}
	}

	public var task: Task {
		return .requestParameters(parameters: parameters, encoding: parameterEncoding)
	}

	public var path: String {
		switch self {
		case .getBookingsByBookingId(let bookingId):
			return "/bookings/\(bookingId)"
		case .getParticipant(let meetingId):
			return "/meetings/\(meetingId)/participants"
		case .getUserBooking:
			return "/bookings/status"
		case .deleteBookings(let id):
			return "/bookings/\(id)"
		case .getTodayAgenda:
			return "/bookings/today"
		}
	}

	public var method: Moya.Method {
		switch self {
		case .getBookingsByBookingId:
			return .get
		case .getParticipant:
			return .get
		case .getUserBooking:
			return .get
		case .deleteBookings(_):
			return .delete
		case .getTodayAgenda:
			return .get
		}
	}

	public var sampleData: Data {
		switch self {
		case .getUserBooking(_):
			return UserBookingsResponse.sampleData
		case .getBookingsByBookingId(_):
			return UserBookingData.sampleData
		case .deleteBookings(_):
			return SuccessResponse(message: "success").toJSONData()
		case .getParticipant(_):
			return ParticipantData.sampleResponseData
		case .getTodayAgenda:
			return UserBookingsResponse.sampleData
		}
	}
}
