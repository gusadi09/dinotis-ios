//
//  EnvironmentApi.swift
//  DinotisApp
//
//  Created by Gus Adi on 30/10/21.
//

import Foundation

let videoAppId = "efd960efdfb941c5bfd17f7223f44046"
let messageAppId = "4b00a6c2950b4fa2bdd207812108f303"

enum EnvironmentApi: String {
	case production = "production"
	case development = "development"
	
	var baseURL: String {
		switch self {
		case .production:
			return "https://api.dinotis.com/api/v1"
		case .development:
			return "https://dev.api.dinotis.com/api/v1"
		}
	}

	var oneSignalAppId: String {
		switch self {
		case .production:
			return "824ac969-01da-4c2a-b146-a91e6d2ea962"
		case .development:
			return "c15c965b-3fbc-4f71-85af-ec02b2b51169"
		}
	}
	
	var openURL: String {
		switch self {
		case .production:
			return "https://app.dinotis.com/"
		case .development:
			return "https://dev.app.dinotis.com/"
		}
	}
	
	var usernameURL: String {
		switch self {
		case .production:
			return "app.dinotis.com/"
		case .development:
			return "dev.app.dinotis.com/"
		}
	}
}
