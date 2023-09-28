//
//  Date+toString.swift
//  
//
//  Created by Gus Adi on 21/12/22.
//

import Foundation

public extension Date {
    var iso8601withFractionalSeconds: String { return Formatter.iso8601withFractionalSeconds.string(from: self) }
    
	func toStringFormat(with format: DateFormatType) -> String {
		let formatter = DateFormatter()
		formatter.locale = Locale(identifier: "en_US_POSIX")
		formatter.dateFormat = format.rawValue

		return formatter.string(from: self)
	}
}

extension ISO8601DateFormatter {
    convenience init(_ formatOptions: Options) {
        self.init()
        self.formatOptions = formatOptions
    }
}

extension Formatter {
    static let iso8601withFractionalSeconds = ISO8601DateFormatter([.withInternetDateTime, .withFractionalSeconds])
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
