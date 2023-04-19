//
//  File.swift
//  
//
//  Created by Gus Adi on 16/01/23.
//

import Foundation

public extension Optional where Wrapped == Int {
	func orZero() -> Int {
		return self ?? 0
	}
}
