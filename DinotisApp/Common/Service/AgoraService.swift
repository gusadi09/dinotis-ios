//
//  AgoraService.swift
//  DinotisApp
//
//  Created by Gus Adi on 08/10/21.
//

import Foundation
import Alamofire
import SwiftUI

class AgoraService {
	static let shared = AgoraService()
	
	let meetRepo = MeetingRepo.shared
	@ObservedObject var network = Monitor.shared
	
	var httpHeader: HTTPHeaders = [
		"Accept-Language": String(Locale.current.identifier.prefix(2))
	]
	
	func startMeeting(with token: String, id: String, completion: @escaping ((StartMeetingResponse?, UnauthResponse?) -> Void)) {
		httpHeader.add(.authorization(bearerToken: token))

		AF.request(meetRepo.startMeeting(with: id), method: .patch, headers: httpHeader)
			.validate(statusCode: 200..<500)
			.responseData { response in
				switch response.response?.statusCode {
				case 200:
					do {
						let data = try JSONDecoder().decode(StartMeetingResponse.self, from: response.data!)
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
	
	func getAllParticipant(with token: String, by meetingId: String, completion: @escaping ((Participant?, UnauthResponse?) -> Void)) {
		httpHeader.add(.authorization(bearerToken: token))
		
		AF.request(meetRepo.getAllParticipant(with: meetingId), method: .get, headers: httpHeader)
			.validate(statusCode: 200..<500)
			.responseData { response in
				switch response.response?.statusCode {
				case 200:
					do {
						if let data = response.data {
							let respon = try JSONDecoder().decode(Participant.self, from: data)
							completion(respon, nil)
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
