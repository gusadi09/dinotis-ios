//
//  KeychainKey.swift
//  EmontirApps
//
//  Created by Gus Adi on 01/12/21.
//

import Foundation

public enum KeychainKey {
	public static let accessToken = "auth.accessToken"
	public static let userId = "auth.userId"
	public static let refreshToken = "auth.refreshToken"
	public static let expireAt = "auth.expireAt"
	public static let userType = "auth.userType"
	public static let isVerified = "auth.isverified"
	public static let userAnnounce = "misc.announcement"
	public static let twilioAccessToken = "auth.twilioAccessToken"
	public static let twilioRole = "twilio.role"
	public static let twilioUserIdentity = "twilio.userIdentity"
	public static let twilioRemoveUserState = "twilio.removeUserState"
    public static let gatewayActive = "home.gatewayActive"
}
