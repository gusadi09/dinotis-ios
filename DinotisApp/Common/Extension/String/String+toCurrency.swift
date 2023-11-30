//
//  Int+toCurrency.swift
//  DinotisApp
//
//  Created by Gus Adi on 16/02/22.
//

import Foundation
import CurrencyFormatter

extension Double {
	func toCurrency() -> String {
		let fm = CurrencyFormatter()

		fm.currency = .rupiah
		fm.locale = CurrencyLocale.indonesian
		fm.decimalDigits = 0

		return fm.string(from: self).orEmpty()
	}
    
    func toPriceFormat() -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "id_ID")
        
        if let formattedNumber = formatter.string(from: NSNumber(value: self)) {
            return formattedNumber.replacingOccurrences(of: "Rp", with: "")
        } else {
            return ""
        }
    }
}

extension String {
	func toCurrency() -> String {
		let fm = CurrencyFormatter()
		
		fm.currency = .rupiah
		fm.locale = CurrencyLocale.indonesian
		fm.decimalDigits = 0
		
		return fm.string(from: Double.init(Int.init(self).orZero())).orEmpty()
	}
	
	func toPriceFormat() -> String {
		let formatter = NumberFormatter()
		formatter.numberStyle = .currency
		formatter.locale = Locale(identifier: "id_ID")
		
		if let number = formatter.string(from: Double.init(Int.init(self).orZero())) {
			return number.replacingOccurrences(of: "Rp", with: "")
		} else {
			return ""
		}
	}
}

