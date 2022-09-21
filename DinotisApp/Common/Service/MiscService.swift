//
//  MiscService.swift
//  DinotisApp
//
//  Created by Gus Adi on 25/09/21.
//

import Foundation
import Alamofire
import SwiftUI

class MiscService {
	static let shared = MiscService()
	
	let miscRepo = MiscRepo.shared
	@ObservedObject var network = Monitor.shared
	
	var httpHeader: HTTPHeaders = [
		"Accept-Language": String(Locale.current.identifier.prefix(2)),
		"Content-Type" : "application/json",
		"Accept" : "application/json"
	]
	
	func getProfession(token: String, completion: @escaping ((ProfessionResponse?, UnauthResponse?) -> Void)) {
		httpHeader.add(.authorization(bearerToken: token))
		
		AF.request(miscRepo.profession, method: .get, headers: httpHeader)
			.validate(statusCode: 200..<500)
			.responseData { response in
				switch response.response?.statusCode {
				case 200:
					do {
						if let serverData = response.data {
							let data = try JSONDecoder().decode(ProfessionResponse.self, from: serverData)
							completion(data, nil)
						} else {
							if self.network.status == .connected {
								let data = UnauthResponse(statusCode: -1, message: NSLocalizedString("cant_connect_server", comment: ""), error: nil)
								completion(nil, data)
							} else {
								let data = UnauthResponse(statusCode: 1, message: NSLocalizedString("connection_warning", comment: ""), error: nil)
								completion(nil, data)
							}
						}
					} catch let error as NSError {
						let data = UnauthResponse(statusCode: error.code, message: error.localizedDescription, error: nil)
						completion(nil, data)
					}
				case 401:
					do {
						if let serverData = response.data {
							let data = try JSONDecoder().decode(UnauthResponse.self, from: serverData)
							completion(nil, data)
						} else {
							let data = UnauthResponse(statusCode: -1, message: NSLocalizedString("cant_connect_server", comment: ""), error: nil)
							completion(nil, data)
						}
					} catch let error as NSError {
						let data = UnauthResponse(statusCode: error.code, message: error.localizedDescription, error: nil)
						completion(nil, data)
					}
				default:
					do {
						if let serverData = response.data {
							let data = try JSONDecoder().decode(UnauthResponse.self, from: serverData)
							completion(nil, data)
						} else {
							if self.network.status == .connected {
								let data = UnauthResponse(statusCode: -1, message: NSLocalizedString("cant_connect_server", comment: ""), error: nil)
								completion(nil, data)
							} else {
								let data = UnauthResponse(statusCode: 1, message: NSLocalizedString("connection_warning", comment: ""), error: nil)
								completion(nil, data)
							}
						}
					} catch let error as NSError {
						let data = UnauthResponse(statusCode: error.code, message: error.localizedDescription, error: nil)
						completion(nil, data)
					}
				}
			}
	}
	
	func getPaymentMethod(completion: @escaping ((PaymentData?, UnauthResponse?) -> Void)) {
		AF.request(miscRepo.paymentMethod, method: .get, headers: httpHeader)
			.validate(statusCode: 200..<500)
			.responseData { response in
				switch response.response?.statusCode {
				case 200:
					do {
						let data = try JSONDecoder().decode(PaymentData.self, from: response.data!)
						completion(data, nil)
					} catch let error as NSError {
						let data = UnauthResponse(statusCode: error.code, message: error.localizedDescription, error: nil)
						completion(nil, data)
					}
				case 500:
					do {
						if let serverData = response.data {
							let data = try JSONDecoder().decode(UnauthResponse.self, from: serverData)
							completion(nil, data)
						} else {
							let data = UnauthResponse(statusCode: -1, message: NSLocalizedString("cant_connect_server", comment: ""), error: nil)
							completion(nil, data)
						}
					} catch let error as NSError {
						let data = UnauthResponse(statusCode: error.code, message: error.localizedDescription, error: nil)
						completion(nil, data)
					}
				default:
					do {
						if let serverData = response.data {
							let data = try JSONDecoder().decode(UnauthResponse.self, from: serverData)
							completion(nil, data)
						} else {
							if self.network.status == .connected {
								let data = UnauthResponse(statusCode: -1, message: NSLocalizedString("cant_connect_server", comment: ""), error: nil)
								completion(nil, data)
							} else {
								let data = UnauthResponse(statusCode: 1, message: NSLocalizedString("connection_warning", comment: ""), error: nil)
								completion(nil, data)
							}
						}
					} catch let error as NSError {
						let data = UnauthResponse(statusCode: error.code, message: error.localizedDescription, error: nil)
						completion(nil, data)
					}
				}
			}
	}
	
	func getBankWithdraw(token: String, completion: @escaping ((BankResponse?, UnauthResponse?) -> Void)) {
		httpHeader.add(.authorization(bearerToken: token))
		
		AF.request(miscRepo.bankWithdraw, method: .get, headers: httpHeader)
			.validate(statusCode: 200..<500)
			.responseData { response in
				switch response.response?.statusCode {
				case 200:
					do {
						let data = try JSONDecoder().decode(BankResponse.self, from: response.data!)
						completion(data, nil)
					} catch let error as NSError {
						let data = UnauthResponse(statusCode: error.code, message: error.localizedDescription, error: nil)
						completion(nil, data)
					}
				case 401:
					do {
						if let serverData = response.data {
							let data = try JSONDecoder().decode(UnauthResponse.self, from: serverData)
							completion(nil, data)
						} else {
							if self.network.status == .connected {
								let data = UnauthResponse(statusCode: -1, message: NSLocalizedString("cant_connect_server", comment: ""), error: nil)
								completion(nil, data)
							} else {
								let data = UnauthResponse(statusCode: 1, message: NSLocalizedString("connection_warning", comment: ""), error: nil)
								completion(nil, data)
							}
						}
					} catch let error as NSError {
						let data = UnauthResponse(statusCode: error.code, message: error.localizedDescription, error: nil)
						completion(nil, data)
					}
				default:
					do {
						if let serverData = response.data {
							let data = try JSONDecoder().decode(UnauthResponse.self, from: serverData)
							completion(nil, data)
						} else {
							if self.network.status == .connected {
								let data = UnauthResponse(statusCode: -1, message: NSLocalizedString("cant_connect_server", comment: ""), error: nil)
								completion(nil, data)
							} else {
								let data = UnauthResponse(statusCode: 1, message: NSLocalizedString("connection_warning", comment: ""), error: nil)
								completion(nil, data)
							}
						}
					} catch let error as NSError {
						let data = UnauthResponse(statusCode: error.code, message: error.localizedDescription, error: nil)
						completion(nil, data)
					}
				}
			}
	}
	
	func extraFee(token: String, meetingId: String, completion: @escaping ((ExtraFeeResponse?, UnauthResponse?) -> Void)) {
		httpHeader.add(.authorization(bearerToken: token))
		
		AF.request(miscRepo.extraFee(meetingId: meetingId), method: .post, headers: httpHeader)
			.validate(statusCode: 200..<500)
			.responseData { response in
				switch response.response?.statusCode {
				case 201:
					do {
						let data = try JSONDecoder().decode(ExtraFeeResponse.self, from: response.data!)
						completion(data, nil)
					} catch let error as NSError {
						let data = UnauthResponse(statusCode: error.code, message: error.localizedDescription, error: nil)
						completion(nil, data)
					}
				case 401:
					do {
						if let serverData = response.data {
							let data = try JSONDecoder().decode(UnauthResponse.self, from: serverData)
							completion(nil, data)
						} else {
							if self.network.status == .connected {
								let data = UnauthResponse(statusCode: -1, message: NSLocalizedString("cant_connect_server", comment: ""), error: nil)
								completion(nil, data)
							} else {
								let data = UnauthResponse(statusCode: 1, message: NSLocalizedString("connection_warning", comment: ""), error: nil)
								completion(nil, data)
							}
						}
					} catch let error as NSError {
						let data = UnauthResponse(statusCode: error.code, message: error.localizedDescription, error: nil)
						completion(nil, data)
					}
				default:
					do {
						if let serverData = response.data {
							let data = try JSONDecoder().decode(UnauthResponse.self, from: serverData)
							completion(nil, data)
						} else {
							if self.network.status == .connected {
								let data = UnauthResponse(statusCode: -1, message: NSLocalizedString("cant_connect_server", comment: ""), error: nil)
								completion(nil, data)
							} else {
								let data = UnauthResponse(statusCode: 1, message: NSLocalizedString("connection_warning", comment: ""), error: nil)
								completion(nil, data)
							}
						}
					} catch let error as NSError {
						let data = UnauthResponse(statusCode: error.code, message: error.localizedDescription, error: nil)
						completion(nil, data)
					}
				}
			}
	}
}
