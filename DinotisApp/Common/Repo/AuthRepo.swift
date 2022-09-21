//
//  AuthRepo.swift
//  DinotisApp
//
//  Created by Gus Adi on 15/09/21.
//

import Foundation

class AuthRepo {
	static let shared = AuthRepo()
	
	let baseUrl  = Configuration.shared.environment.baseURL
	
	var login: URL {
		return URL(string: baseUrl + "/auth/login")!
	}
	
	var profile: URL {
		return URL(string: baseUrl + "/users/me")!
	}
	
	var refreshToken: URL {
		return URL(string: baseUrl + "/auth/refresh")!
	}
	
	var resendMail: URL {
		return URL(string: baseUrl + "/auth/email/send")!
	}
	
	var updateUser: URL {
		
		return URL(string: baseUrl + "/users")!
	}
	
	var forgetPassword: URL {
		return URL(string: baseUrl + "/auth/password/email")!
	}
	
	var changePassword: URL {
		return URL(string: baseUrl + "/users/password")!
	}
	
	var changePasswordOauth: URL {
		return URL(string: baseUrl + "/users/password/oauth")!
	}
	
	var changeEmail: URL {
		return URL(string: baseUrl + "/users/email")!
	}
	
	var usernameAvailabilty: URL {
		return URL(string: baseUrl + "/users/username/availability")!
	}
	
	var usernameAvailabiltyEdit: URL {
		return URL(string: baseUrl + "/users/username/availability/edit")!
	}
	
	var usernameSuggest: URL {
		return URL(string: baseUrl + "/users/username/suggestion")!
	}
	
	var userBalanceCurrent: URL {
		return URL(string: baseUrl + "/balances/user/current")!
	}
}
