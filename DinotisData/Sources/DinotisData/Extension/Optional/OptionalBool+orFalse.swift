//
//  File.swift
//  
//
//  Created by Gus Adi on 16/01/23.
//

import Foundation

public extension Optional where Wrapped == Bool {
	func orFalse() -> Bool {
		return self ?? false
	}
}
