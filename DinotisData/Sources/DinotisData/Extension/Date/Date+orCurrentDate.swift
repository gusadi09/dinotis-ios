//
//  Date+orCurrentDate.swift
//  
//
//  Created by Gus Adi on 21/12/22.
//

import Foundation

public extension Optional where Wrapped == Date {
	func orCurrentDate() -> Date {
		return self ?? Date()
	}
}
