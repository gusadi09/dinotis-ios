//
//  StateObservable.swift
//  DinotisApp
//
//  Created by Gus Adi on 18/11/21.
//

import Foundation
import SwiftKeychainWrapper
import AVFoundation

class StateObservable: ObservableObject {
	static let shared = StateObservable()
	
	private let keychain: KeychainWrapper
	
	@Published var accessToken: String {
		didSet {
			keychain.set(accessToken, forKey: KeychainKey.accessToken)
		}
	}
	
	@Published var refreshToken: String {
		didSet {
			keychain.set(refreshToken, forKey: KeychainKey.refreshToken)
		}
	}
	
	@Published var isVerified: String {
		didSet {
			keychain.set(isVerified, forKey: KeychainKey.isVerified)
		}
	}
	
	@Published var userType: Int {
		didSet {
			keychain.set(userType, forKey: KeychainKey.userType)
		}
	}

	@Published var isAnnounceShow: Bool {
		didSet {
			keychain.set(isAnnounceShow, forKey: KeychainKey.userAnnounce)
		}
	}

	@Published var twilioAccessToken: String {
		didSet {
			keychain.set(twilioAccessToken, forKey: KeychainKey.twilioAccessToken)
		}
	}

	@Published var twilioRole: String {
		didSet {
			keychain.set(twilioRole, forKey: KeychainKey.twilioRole)
		}
	}

	@Published var twilioUserIdentity: String {
		didSet {
			keychain.set(twilioUserIdentity, forKey: KeychainKey.twilioUserIdentity)
		}
	}

	@Published var isRemoveUser: Bool {
		didSet {
			keychain.set(isRemoveUser, forKey: KeychainKey.twilioRemoveUserState)
		}
	}
    
    @Published var spotlightedIdentity = ""
	
	@Published var isShowInvoice = false
	@Published var bookId = ""

	@Published var isGoToDetailSchedule = false
	@Published var meetingId = ""

	@Published var cameraPositionUsed = AVCaptureDevice.Position.front
	
	init(keychain: KeychainWrapper = KeychainWrapper.standard) {
		self.keychain = keychain
		
		self.accessToken = self.keychain.string(forKey: KeychainKey.accessToken).orEmpty()
		self.refreshToken = self.keychain.string(forKey: KeychainKey.refreshToken).orEmpty()
		self.userType = self.keychain.integer(forKey: KeychainKey.userType).orZero()
		self.isVerified = self.keychain.string(forKey: KeychainKey.isVerified).orEmpty()
		self.isAnnounceShow = self.keychain.bool(forKey: KeychainKey.userAnnounce) ?? false
		self.twilioAccessToken = self.keychain.string(forKey: KeychainKey.twilioAccessToken).orEmpty()
		self.twilioRole = self.keychain.string(forKey: KeychainKey.twilioRole).orEmpty()
		self.twilioUserIdentity = self.keychain.string(forKey: KeychainKey.twilioUserIdentity).orEmpty()
		self.isRemoveUser = self.keychain.bool(forKey: KeychainKey.twilioRemoveUserState) ?? false
	}
}
