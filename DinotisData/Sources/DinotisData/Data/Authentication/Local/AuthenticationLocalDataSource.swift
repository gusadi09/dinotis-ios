//
//  File.swift
//  
//
//  Created by Gus Adi on 19/01/23.
//

import Foundation

public protocol AuthenticationLocalDataSource {
	func saveToKeychain(_ value: String, forKey key: String) async
	func loadFromKeychain(forKey key: String) async -> String
}
