//
//  Date+toString.swift
//  
//
//  Created by Gus Adi on 21/12/22.
//

import Foundation

public extension Date {
	func toStringFormat(with format: DateFormatType) -> String {
		let formatter = DateFormatter()
		formatter.locale = Locale.current
		formatter.dateFormat = format.rawValue

		return formatter.string(from: self)
	}
}

public enum DateFormatType: String {
	case utc = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
	case ddMMMyyyy = "dd MMM yyyy"
	case yyyyMMdd = "yyyy-MM-dd"
	case ddMMMMyyyy = "dd MMMM yyyy"
	case ddMMMyyyyHHmm = "dd MMM yyyy, HH:mm"
	case EEEEddMMMMyyyy = "EEEE, dd MMMM yyyy"
	case HHmm = "HH.mm"
	case HHmmss = "HH:mm:ss"
	case slashddMMyyyy = "dd / MM / yyyy"
	case ddMMyyyyHHmm = "dd/MM/yyyy HH:mm"
	case negotiationBubbleChat = "HH:mm - dd MMMM yyyy"
	case EEEEddMMMyyyHHmm = "EEEE, dd MMM yyyy HH:mm"
}
