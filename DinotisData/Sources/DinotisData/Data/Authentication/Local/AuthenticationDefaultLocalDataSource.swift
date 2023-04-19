//
//  File.swift
//  
//
//  Created by Gus Adi on 19/01/23.
//

import Foundation
import SwiftKeychainWrapper

public final class AuthenticationDefaultLocalDataSource: AuthenticationLocalDataSource {

	private let keychain: KeychainWrapper

	public init(keychain: KeychainWrapper = KeychainWrapper.standard) {
		self.keychain = keychain
	}

	public func saveToKeychain(_ value: String, forKey key: String) async {
		keychain.set(value, forKey: key)
	}

	public func loadFromKeychain(forKey key: String) async -> String {
		keychain.string(forKey: key).orEmpty()
	}
}
