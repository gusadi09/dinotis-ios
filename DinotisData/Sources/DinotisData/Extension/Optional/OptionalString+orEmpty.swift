//
//  OptionalString+orEmpty.swift
//  
//
//  Created by Gus Adi on 02/12/22.
//

import Foundation

public extension Optional where Wrapped == String {
	func orEmpty() -> String {
		return self ?? ""
	}
}
