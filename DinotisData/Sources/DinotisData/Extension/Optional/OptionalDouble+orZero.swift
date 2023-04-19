//
//  File.swift
//  
//
//  Created by Gus Adi on 16/01/23.
//

import Foundation

public extension Optional where Wrapped == Double {
	func orZero() -> Double {
		return self ?? 0.0
	}
}
