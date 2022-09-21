//
//  OptionalInt+orZero.swift
//  DinotisApp
//
//  Created by Gus Adi on 13/12/21.
//

import Foundation

extension Optional where Wrapped == Int {
	func orZero() -> Int {
		return self ?? 0
	}
}
