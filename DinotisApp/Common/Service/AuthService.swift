//
//  AuthService.swift
//  DinotisApp
//
//  Created by Gus Adi on 15/09/21.
//

import Foundation
import Alamofire
import SwiftUI

class AuthService {
	static let shared = AuthService()
	
	let authRepo = AuthRepo.shared
	
	@ObservedObject var network = Monitor.shared
	
	var httpHeader: HTTPHeaders = [
		"Accept-Language": String(Locale.current.identifier.prefix(2)),
		"Content-Type" : "application/json",
		"Accept" : "application/json"
	]
	
	func login(loginForm: LoginBody, completion: @escaping ((LoginResponse?, UnauthResponse?) -> Void)) {
		AF.request(authRepo.login, method: .post, parameters: loginForm, encoder: JSONParameterEncoder.default, headers: httpHeader)
			.validate(statusCode: 200..<500)
			.responseData { response in
				switch response.response?.statusCode {
				case 201:
					do {
						if let serverData = response.data {
							let data = try JSONDecoder().decode(LoginResponse.self, from: serverData)
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
				case 422:
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
	
	func getUser(token: String, completion: @escaping ((Users?, UnauthResponse?) -> Void)) {
		httpHeader.add(.authorization(bearerToken: token))
		
		AF.request(authRepo.profile, method: .get, headers: httpHeader)
			.validate(statusCode: 200..<500)
			.responseData { response in
				switch response.response?.statusCode {
				case 200:
					do {
						if let serverData = response.data {
							let data = try JSONDecoder().decode(Users.self, from: serverData)
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
	
	func refreshToken(with refreshToken: String, completion: @escaping ((Result<LoginResponse, AFError>) -> Void)) {
		httpHeader.add(.authorization(bearerToken: refreshToken))
		
		AF.request(authRepo.refreshToken, method: .post, headers: httpHeader)
			.validate(statusCode: 200..<500)
			.responseDecodable(of: LoginResponse.self) { response in
				completion(response.result)
			}
	}
	
	func updateUser(token: String, with userProfile: UpdateUser, completion: @escaping ((Users?, UnauthResponse?) -> Void)) {
		httpHeader.add(.authorization(bearerToken: token))
		
		AF.request(authRepo.updateUser, method: .put, parameters: userProfile, encoder: JSONParameterEncoder.default, headers: httpHeader)
			.validate(statusCode: 200..<500)
			.responseString { response in
				switch response.response?.statusCode {
				case 200:
					do {
						if let serverData = response.data {
							let data = try JSONDecoder().decode(Users.self, from: serverData)
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
	
	func forgetPassword(params: ResendOtp, completion: @escaping ((Result<String, AFError>) -> Void)) {
		AF.request(authRepo.forgetPassword, method: .post, parameters: params, encoder: JSONParameterEncoder.default, headers: httpHeader)
			.validate(statusCode: 200..<500)
			.responseString { response in
				completion(response.result)
			}
	}
	
	func changePassword(token: String, params: ChangePassword, completion: @escaping ((String?, UnauthResponse?) -> Void)) {
		httpHeader.add(.authorization(bearerToken: token))
		
		AF.request(authRepo.changePassword, method: .put, parameters: params, encoder: JSONParameterEncoder.default, headers: httpHeader)
			.validate(statusCode: 200..<500)
			.responseString { response in
				switch response.response?.statusCode {
				case 204:
					completion(response.value, nil)
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
				case 500:
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
	
	func changePasswordOauth(token: String, params: ChangePasswordOauth, completion: @escaping ((String?, UnauthResponse?) -> Void)) {
		httpHeader.add(.authorization(bearerToken: token))
		
		AF.request(authRepo.changePasswordOauth, method: .put, parameters: params, encoder: JSONParameterEncoder.default, headers: httpHeader)
			.validate(statusCode: 200..<500)
			.responseString { response in
				switch response.response?.statusCode {
				case 204:
					completion(response.value, nil)
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
				case 500:
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
	
	func changeEmail(token: String, params: ResendOtp, completion: @escaping((String?, UnauthResponse?) -> Void)) {
		httpHeader.add(.authorization(bearerToken: token))
		
		AF.request(authRepo.changeEmail, method: .patch, parameters: params, encoder: JSONParameterEncoder.default, headers: httpHeader)
			.validate(statusCode: 200..<500)
			.responseString { response in
				switch response.response?.statusCode {
				case 204:
					completion(response.value, nil)
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
				case 500:
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
	
	func usernameSuggestion(token: String, name: SuggestionBody, completion: @escaping((UsernameBody?, UnauthResponse?) -> Void)) {
		httpHeader.add(.authorization(bearerToken: token))
		
		AF.request(authRepo.usernameSuggest, method: .post, parameters: name, encoder: JSONParameterEncoder.default, headers: httpHeader)
			.validate(statusCode: 200..<500)
			.responseString { response in
				switch response.response?.statusCode {
				case 201:
					do {
						let data = try JSONDecoder().decode(UsernameBody.self, from: response.data!)
						completion(data, nil)
					} catch let error as NSError {
						let data = UnauthResponse(statusCode: error.code, message: error.localizedDescription, error: nil)
						completion(nil, data)
					}
				case 409:
					do {
						let data = try JSONDecoder().decode(UnauthResponse.self, from: response.data!)
						completion(nil, data)
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
	
	func usernameAvailability(token: String, username: UsernameBody, completion: @escaping((String?, UnauthResponse?) -> Void)) {
		httpHeader.add(.authorization(bearerToken: token))
		
		AF.request(authRepo.usernameAvailabilty, method: .post, parameters: username, encoder: JSONParameterEncoder.default, headers: httpHeader)
			.validate(statusCode: 200..<500)
			.responseString { response in
				switch response.response?.statusCode {
				case 204:
					completion(response.value, nil)
				case 409:
					do {
						let data = try JSONDecoder().decode(UnauthResponse.self, from: response.data!)
						completion(nil, data)
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
	
	func usernameAvailabilityEdit(token: String, username: UsernameBody, completion: @escaping((String?, UnauthResponse?) -> Void)) {
		httpHeader.add(.authorization(bearerToken: token))
		
		AF.request(authRepo.usernameAvailabiltyEdit, method: .post, parameters: username, encoder: JSONParameterEncoder.default, headers: httpHeader)
			.validate(statusCode: 200..<500)
			.responseString { response in
				switch response.response?.statusCode {
				case 204:
					completion(response.value, nil)
				case 409:
					do {
						let data = try JSONDecoder().decode(UnauthResponse.self, from: response.data!)
						completion(nil, data)
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
	
	func currentBalance(token: String, completion: @escaping((CurrentBalance?, UnauthResponse?) -> Void)) {
		httpHeader.add(.authorization(bearerToken: token))
		
		AF.request(authRepo.userBalanceCurrent, method: .get, headers: httpHeader)
			.validate(statusCode: 200..<500)
			.responseString { response in
				switch response.response?.statusCode {
				case 200:
					do {
						let data = try JSONDecoder().decode(CurrentBalance.self, from: response.data!)
						completion(data, nil)
					} catch let error as NSError {
						let data = UnauthResponse(statusCode: error.code, message: error.localizedDescription, error: nil)
						completion(nil, data)
					}
				case 401:
					do {
						let data = try JSONDecoder().decode(UnauthResponse.self, from: response.data!)
						completion(nil, data)
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
