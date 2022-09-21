//
//  String+Date.swift
//  NewsApp
//
//  Created by Gus Adi on 05/11/21.
//

import Foundation

extension String {
	func toDate(format: DateFormat) -> Date? {
		let formatter = DateFormatter()
		formatter.locale = Locale.current
		formatter.dateFormat = format.rawValue
		
		return formatter.date(from: self)
	}
}
