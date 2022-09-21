//
//  SearchingService.swift
//  DinotisApp
//
//  Created by Gus Adi on 30/09/21.
//

import Foundation
import Alamofire
import SwiftUI

class SearchingService {
	static let shared = SearchingService()
	
	let searchRepo = SearchRepo.shared
	@ObservedObject var network = Monitor.shared
	
	var httpHeader: HTTPHeaders = [
		"Accept-Language": String(Locale.current.identifier.prefix(2)),
		"Content-Type": "multipart/form-data"
	]
	
	func searchTalent(with token: String, by query: QuerySearch, completion: @escaping ((SearchResponse?, UnauthResponse?) -> Void)) {
		httpHeader.add(.authorization(bearerToken: token))
		
		searchRepo.searchQuery = QuerySearch(query: query.query, skip: query.skip, take: query.take, profession: query.profession)
		
		AF.request(searchRepo.search, method: .get, headers: httpHeader)
			.validate(statusCode: 200..<500)
			.responseData { response in
				switch response.response?.statusCode {
				case 200:
					do {
						let data = try JSONDecoder().decode(SearchResponse.self, from: response.data!)
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
	
	func getTalentFromSearch(with username: String, completion: @escaping ((TalentFromSearch?, UnauthResponse?) -> Void)) {
		searchRepo.username = username
		
		AF.request(searchRepo.getTalent, method: .get, headers: httpHeader)
			.validate(statusCode: 200..<500)
			.responseData { response in
				switch response.response?.statusCode {
				case 200:
					do {
						let data = try JSONDecoder().decode(TalentFromSearch.self, from: response.data!)
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
