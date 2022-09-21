//
//  OTPType.swift
//  DinotisApp
//
//  Created by Gus Adi on 18/04/22.
//

import Foundation

enum OTPType {
	case register
	case forgetPassword
	case login
}

enum DeliveryOTPVia {
	case whatsapp
	case sms
}

extension DeliveryOTPVia {
	var name: String {
		switch self {
		case .whatsapp:
			return "whatsapp"
		case .sms:
			return "sms"
		}
	}
}
