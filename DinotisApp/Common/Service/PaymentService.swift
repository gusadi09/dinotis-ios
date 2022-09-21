//
//  PaymentService.swift
//  DinotisApp
//
//  Created by Gus Adi on 07/10/21.
//

import Foundation
import Alamofire
import SwiftUI

class PaymentService {
	static let shared = PaymentService()
	
	let payRepo = PaymentRepo.shared
	@ObservedObject var network = Monitor.shared
	
	var httpHeader: HTTPHeaders = [
		"Accept-Language": String(Locale.current.identifier.prefix(2)),
		"Content-Type" : "application/json",
		"Accept" : "application/json"
	]
	
	private func loadJson(
		fromURL url: URL,
		completion: @escaping (Result<Data, Error>) -> Void
	) {
		
		URLSession.shared.dataTask(with: url) { (data, _, error) in
			if let error = error {
				completion(.failure(error))
			}
			
			if let data = data {
				
				completion(.success(data))
			}
		}.resume()
		
	}
	
	func paymentInstruction(completion: @escaping (([PaymentInstruction]?, UnauthResponse?) -> Void)) {
		loadJson(fromURL: payRepo.paymentInstruction) { result in
			switch result {
			case .success(let data):
				do {
					let decodedData = try JSONDecoder().decode([PaymentInstruction].self,
																										 from: data)
					
					completion(decodedData, nil)
				} catch {
					let data = UnauthResponse(statusCode: 0, message: error.localizedDescription, fields: nil, error: nil)
					completion(nil, data)
				}
				
			case .failure(let error):
				let data = UnauthResponse(statusCode: 0, message: error.localizedDescription, fields: nil, error: nil)
				completion(nil, data)
			}
		}
	}
	
	func bookingPay(with token: String, by payment: BookingPay, completion: @escaping ((BookingData?, UnauthResponse?) -> Void)) {
		httpHeader.add(.authorization(bearerToken: token))
		
		AF.request(payRepo.bookingsPay, method: .post, parameters: payment, encoder: JSONParameterEncoder.default, headers: httpHeader)
			.validate(statusCode: 200..<500)
			.responseData { response in
				switch response.response?.statusCode {
				case 201:
					do {
						let data = try JSONDecoder().decode(BookingData.self, from: response.data!)
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
				default :
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
	
	func getInvoice(with token: String, by bookingId: String, completion: @escaping ((Invoice?, UnauthResponse?) -> Void)) {
		httpHeader.add(.authorization(bearerToken: token))
		
		AF.request(payRepo.getInvoice(bookingId: bookingId), method: .get, headers: httpHeader)
			.validate(statusCode: 200..<500)
			.responseData { response in
				switch response.response?.statusCode {
				case 200:
					do {
						if let dataResponse = response.data {
							let data = try JSONDecoder().decode(Invoice.self, from: dataResponse)
							completion(data, nil)
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
				default :
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
