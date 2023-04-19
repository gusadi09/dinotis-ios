//
//  StateObservable.swift
//  DinotisApp
//
//  Created by Gus Adi on 18/11/21.
//

import Foundation
import SwiftKeychainWrapper
import AVFoundation

public final class StateObservable: ObservableObject {
	public static let shared = StateObservable()
	
	private let keychain: KeychainWrapper
	
	@Published public var accessToken: String {
		didSet {
			keychain.set(accessToken, forKey: KeychainKey.accessToken)
		}
	}
    
    @Published public var userId: String {
        didSet {
            keychain.set(userId, forKey: KeychainKey.userId)
        }
    }
	
	@Published public var refreshToken: String {
		didSet {
			keychain.set(refreshToken, forKey: KeychainKey.refreshToken)
		}
	}
	
	@Published public var isVerified: String {
		didSet {
			keychain.set(isVerified, forKey: KeychainKey.isVerified)
		}
	}
	
	@Published public var userType: Int {
		didSet {
			keychain.set(userType, forKey: KeychainKey.userType)
		}
	}

	@Published public var isAnnounceShow: Bool {
		didSet {
			keychain.set(isAnnounceShow, forKey: KeychainKey.userAnnounce)
		}
	}

	@Published public var twilioAccessToken: String {
		didSet {
			keychain.set(twilioAccessToken, forKey: KeychainKey.twilioAccessToken)
		}
	}

	@Published public var twilioRole: String {
		didSet {
			keychain.set(twilioRole, forKey: KeychainKey.twilioRole)
		}
	}

	@Published public var twilioUserIdentity: String {
		didSet {
			keychain.set(twilioUserIdentity, forKey: KeychainKey.twilioUserIdentity)
		}
	}

	@Published public var isRemoveUser: Bool {
		didSet {
			keychain.set(isRemoveUser, forKey: KeychainKey.twilioRemoveUserState)
		}
	}
    
    @Published public var spotlightedIdentity = ""
	
	@Published public var isShowInvoice = false
	@Published public var bookId = ""
    @Published public var usernameCreator = ""

	@Published public var isGoToDetailSchedule = false
	@Published public var meetingId = ""

	@Published public var cameraPositionUsed = AVCaptureDevice.Position.front
	
	public init(keychain: KeychainWrapper = KeychainWrapper.standard) {
		self.keychain = keychain
		
		self.accessToken = self.keychain.string(forKey: KeychainKey.accessToken).orEmpty()
        self.userId = self.keychain.string(forKey: KeychainKey.userId).orEmpty()
		self.refreshToken = self.keychain.string(forKey: KeychainKey.refreshToken).orEmpty()
		self.userType = self.keychain.integer(forKey: KeychainKey.userType).orZero()
		self.isVerified = self.keychain.string(forKey: KeychainKey.isVerified).orEmpty()
		self.isAnnounceShow = self.keychain.bool(forKey: KeychainKey.userAnnounce) ?? false
		self.twilioAccessToken = self.keychain.string(forKey: KeychainKey.twilioAccessToken).orEmpty()
		self.twilioRole = self.keychain.string(forKey: KeychainKey.twilioRole).orEmpty()
		self.twilioUserIdentity = self.keychain.string(forKey: KeychainKey.twilioUserIdentity).orEmpty()
		self.isRemoveUser = self.keychain.bool(forKey: KeychainKey.twilioRemoveUserState) ?? false
	}
    
    @MainActor
    func setToken(token: LoginTokenData) {
        self.refreshToken = token.refreshToken.orEmpty()
        self.accessToken = token.accessToken.orEmpty()
    }
}
