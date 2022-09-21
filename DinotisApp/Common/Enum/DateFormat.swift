//
//  DateFormat.swift
//  NewsApp
//
//  Created by Gus Adi on 05/11/21.
//

import Foundation

enum DateFormat: String {
	case utc = "yyyy-MM-dd'T'HH:mm:ss'Z'"
	case utcV2 = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
	case ddMMMyyyy = "dd MMM yyyy"
	case yyyyMMdd = "yyyy-MM-dd"
	case ddMMMMyyyy = "dd MMMM yyyy"
	case ddMMMyyyyHHmm = "dd MMM yyyy, HH:mm"
	case EEEEddMMMMyyyy = "EEEE, dd MMMM yyyy"
	case HHmm = "HH.mm"
	case HHmmss = "HH:mm:ss"
	case ddMMyyyyHHmm = "dd/MM/yyyy HH:mm"
}
