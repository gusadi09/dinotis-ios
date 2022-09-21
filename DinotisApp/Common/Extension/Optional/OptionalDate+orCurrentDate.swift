//
//  OptionalDate+orCurrentDate.swift
//  DinotisApp
//
//  Created by Gus Adi on 13/12/21.
//

import Foundation

extension Optional where Wrapped == Date {
	func orCurrentDate() -> Date {
		return self ?? Date()
	}
}
