//
//  OnChangeExt.swift
//  DinotisApp
//
//  Created by Gus Adi on 19/08/21.
//

import SwiftUI
import Combine

extension View {
	/// A backwards compatible wrapper for iOS 14 `onChange`
	@ViewBuilder func valueChanged<T: Equatable>(value: T, onChange: @escaping (T) -> Void) -> some View {
		if #available(iOS 14.0, *) {
			self.onChange(of: value, perform: onChange)
		} else {
			self.onReceive(Just(value)) { (value) in
				onChange(value)
			}
		}
	}
}

extension String {
	func toDecimalWithAutoLocale() -> Decimal? {
		let formatter = NumberFormatter()
		formatter.numberStyle = .decimal
		
		formatter.locale = Locale(identifier: "id_ID")
		
		if let number = formatter.number(from: self) {
			return number.decimalValue
		}
		
		return nil
	}
	
	func toDoubleWithAutoLocale() -> Double? {
		guard let decimal = self.toDecimalWithAutoLocale() else {
			return nil
		}
		
		return NSDecimalNumber(decimal:decimal).doubleValue
	}
}
