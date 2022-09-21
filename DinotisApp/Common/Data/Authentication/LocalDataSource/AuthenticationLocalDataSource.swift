//
//  AuthenticationLocalDataSource.swift
//  DinotisApp
//
//  Created by Gus Adi on 14/02/22.
//

import Foundation

protocol AuthenticationLocalDataSource {
	func saveToKeychain(_ value: String, forKey key: String)
	func loadFromKeychain(forKey key: String) -> String
}
