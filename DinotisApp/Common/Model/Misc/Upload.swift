//
//  Upload.swift
//  DinotisApp
//
//  Created by Gus Adi on 27/09/21.
//

import Foundation

struct UploadResponse: Codable {
	var url: String
}

struct PhotoProfileUrl: Codable {
	var profilePhoto: String
}

struct UploadMultipleResponse: Codable {
    var urls: [String]?
}

struct UserHightlightUrl: Codable {
    var userHightlight: [String]?
}
