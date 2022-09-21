//
//  NSDecimalNumber+toString.swift
//  DinotisApp
//
//  Created by Gus Adi on 18/06/22.
//

import Foundation
import StoreKit

extension SKProduct {
	func priceToString() -> String {
		let formatter = NumberFormatter()
		formatter.numberStyle = .currency
		formatter.locale = self.priceLocale
		
		var cost = formatter.string(from: self.price)
		cost = cost?.replacingOccurrences(of: "IDR", with: "")

		return cost.orEmpty()
	}
}
