//
//  UploadRepo.swift
//  DinotisApp
//
//  Created by Gus Adi on 27/09/21.
//

import Foundation

class UploadRepo {
	static let shared = UploadRepo()
	
	let baseUrl  = Configuration.shared.environment.baseURL
	
	var uploads: URL {
		return URL(string: baseUrl + "/uploads/single")!
	}
    
    var uploadsMultiple: URL {
        return URL(string: baseUrl + "/uploads/multiple")!
    }
	
	var updateImage: URL {
		return URL(string: baseUrl + "/users/profile-photo")!
	}
}
