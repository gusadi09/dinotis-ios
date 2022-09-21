//
//  OptionalDouble+OrZero.swift
//  DinotisApp
//
//  Created by Gus Adi on 13/12/21.
//

import Foundation

extension Optional where Wrapped == Double {
	func orZero() -> Double {
		return self ?? 0.0
	}
}
