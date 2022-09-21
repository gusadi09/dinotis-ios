//
//  KeychainKey.swift
//  EmontirApps
//
//  Created by Gus Adi on 01/12/21.
//

import Foundation

enum KeychainKey {
	static let accessToken = "auth.accessToken"
	static let refreshToken = "auth.refreshToken"
	static let expireAt = "auth.expireAt"
	static let userType = "auth.userType"
	static let isVerified = "auth.isverified"
	static let userAnnounce = "misc.announcement"
	static let twilioAccessToken = "auth.twilioAccessToken"
	static let twilioRole = "twilio.role"
	static let twilioUserIdentity = "twilio.userIdentity"
	static let twilioRemoveUserState = "twilio.removeUserState"
}
