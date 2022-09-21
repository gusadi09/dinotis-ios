//
//  BookingsTargetType.swift
//  DinotisApp
//
//  Created by Gus Adi on 11/03/22.
//

import Foundation
import Moya

enum BookingsTargetType {
	case getBookingsByBookingId(String)
	case getParticipant(String)
}

extension BookingsTargetType: DinotisTargetType, AccessTokenAuthorizable {
	var parameters: [String : Any] {
		switch self {
		case .getBookingsByBookingId:
			return [:]
		case .getParticipant:
			return [:]
		}
	}
	
	var authorizationType: AuthorizationType? {
		return .bearer
	}
	
	var parameterEncoding: Moya.ParameterEncoding {
		switch self {
		case .getBookingsByBookingId:
			return URLEncoding.default
		case .getParticipant:
			return URLEncoding.default
		}
	}
	
	var task: Task {
		return .requestParameters(parameters: parameters, encoding: parameterEncoding)
	}
	
	var path: String {
		switch self {
		case .getBookingsByBookingId(let bookingId):
			return "/bookings/\(bookingId)"
		case .getParticipant(let meetingId):
			return "/meetings/\(meetingId)/participants"
		}
	}
	
	var method: Moya.Method {
		switch self {
		case .getBookingsByBookingId:
			return .get
		case .getParticipant:
			return .get
		}
	}
}
