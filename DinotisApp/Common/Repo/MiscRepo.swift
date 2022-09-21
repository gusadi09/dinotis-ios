//
//  MiscRepo.swift
//  DinotisApp
//
//  Created by Gus Adi on 25/09/21.
//

import Foundation

class MiscRepo {
	static let shared = MiscRepo()
	
	let baseUrl  = Configuration.shared.environment.baseURL
	
	var profession: URL {
		return URL(string: baseUrl + "/professions")!
	}
	
	var paymentMethod: URL {
		return URL(string: baseUrl + "/payment-methods")!
	}
	
	var bankWithdraw: URL {
		return URL(string: baseUrl + "/banks")!
	}
	
	func extraFee(meetingId: String) -> URL {
		return URL(string: baseUrl + "/bookings/extra-fee/\(meetingId)")!
	}
}
