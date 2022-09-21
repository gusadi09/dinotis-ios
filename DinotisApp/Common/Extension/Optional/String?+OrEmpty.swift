//
//  String?+OrEmpty.swift
//  DinotisApp
//
//  Created by Gus Adi on 12/02/22.
//

import Foundation

extension Optional where Wrapped == String {
	func orEmpty() -> String {
		return self ?? ""
	}
}
