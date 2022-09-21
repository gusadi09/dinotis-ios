//
//  PaymentRepo.swift
//  DinotisApp
//
//  Created by Gus Adi on 07/10/21.
//

import Foundation

class PaymentRepo {
	static let shared = PaymentRepo()
	
	let baseUrl  = Configuration.shared.environment.baseURL
	
	var bookingId = ""
	
	var bookingsPay: URL {
		return URL(string: baseUrl + "/bookings")!
	}
	
	func getInvoice(bookingId: String) -> URL {
		return URL(string: baseUrl + "/virtual-accounts/booking/\(bookingId)")!
	}
	
	var paymentInstruction: URL {
		return URL(string: "\(Configuration.shared.environment.openURL)json/payment-method-how-to.json")!
	}
}
