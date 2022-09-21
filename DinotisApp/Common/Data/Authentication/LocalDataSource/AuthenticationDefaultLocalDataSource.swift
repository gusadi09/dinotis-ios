//
//  AuthenticationDefaultLocalDataSource.swift
//  DinotisApp
//
//  Created by Gus Adi on 14/02/22.
//

import Foundation
import SwiftKeychainWrapper

final class AuthenticationDefaultLocalDataSource: AuthenticationLocalDataSource {
	
	private let keychain: KeychainWrapper
	
	init(keychain: KeychainWrapper = KeychainWrapper.standard) {
		self.keychain = keychain
	}
	
	func saveToKeychain(_ value: String, forKey key: String) {
		keychain.set(value, forKey: key)
	}
	
	func loadFromKeychain(forKey key: String) -> String {
		keychain.string(forKey: key).orEmpty()
	}
}
