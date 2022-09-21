//
//  UploadService.swift
//  DinotisApp
//
//  Created by Gus Adi on 27/09/21.
//

import Foundation
import Alamofire
import UIKit
import SwiftUI

class UploadService {
	static let shared = UploadService()
	
	let upRepo = UploadRepo.shared
	@ObservedObject var network = Monitor.shared
	
	var httpHeader: HTTPHeaders = [
		"Accept-Language": String(Locale.current.identifier.prefix(2)),
		"Content-Type": "multipart/form-data"
	]
	
	func uploadSingle(image: UIImage, completion: @escaping ((UploadResponse?, UnauthResponse?) -> Void)) {
		AF.upload(multipartFormData: { multiPartFormData in
			multiPartFormData.append(
				image.jpegData(compressionQuality: 0.5) ?? Data(),
				withName: "file",
				fileName: "profile-image.png",
				mimeType: "image/png"
			)
		}, to: upRepo.uploads, method: .post, headers: httpHeader)
		.validate(statusCode: 200..<500)
		.responseString { result in
			switch result.response?.statusCode {
			case 201:
				do {
					let data = try JSONDecoder().decode(UploadResponse.self, from: result.data!)
					completion(data, nil)
				} catch let error as NSError {
					let data = UnauthResponse(statusCode: error.code, message: error.localizedDescription, error: nil)
					completion(nil, data)
				}
			case 401:
				do {
					if let serverData = result.data {
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
					if let serverData = result.data {
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
					if let serverData = result.data {
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
					if let serverData = result.data {
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
	
	func updateImage(token: String, url: PhotoProfileUrl, completion: @escaping ((String?, UnauthResponse?) -> Void)) {
		httpHeader.add(.authorization(bearerToken: token))
		
		AF.request(upRepo.updateImage, method: .patch, headers: httpHeader)
			.validate(statusCode: 200..<500)
			.responseString { response in
				switch response.response?.statusCode {
				case 200:
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
    
    func uploadUserHighlight(image: [UIImage], completion: @escaping ((UploadMultipleResponse?, UnauthResponse?) -> Void)) {
        AF.upload(multipartFormData: { multiPartFormData in
            for img in image {
                multiPartFormData.append(
                    img.jpegData(compressionQuality: 0.5) ?? Data(),
                    withName: "files",
                    fileName: "hightlight-image.png",
                    mimeType: "image/png"
                )
            }
        }, to: upRepo.uploadsMultiple, method: .post, headers: httpHeader)
        .validate(statusCode: 200..<500)
        .responseString { result in
            switch result.response?.statusCode {
            case 201:
                do {
                    let data = try JSONDecoder().decode(UploadMultipleResponse.self, from: result.data!)
                    completion(data, nil)
                } catch let error as NSError {
                    let data = UnauthResponse(statusCode: error.code, message: error.localizedDescription, error: nil)
                    completion(nil, data)
                }
            case 401:
                do {
                    if let serverData = result.data {
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
                    if let serverData = result.data {
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
                    if let serverData = result.data {
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
                    if let serverData = result.data {
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
