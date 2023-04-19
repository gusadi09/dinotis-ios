//
//  File.swift
//  
//
//  Created by Gus Adi on 16/01/23.
//

import Foundation

public enum LocalizationDataText {
	public static let internalServerErrorText = NSLocalizedString(
		"internal_server_error_text",
		bundle: .module,
		comment: "usage for internal server error"
	)
	public static func cashbackCoinText(_ value: String) -> String {
		String(format: NSLocalizedString("cashback_coin_text", bundle: .module, comment: ""), value)
	}
	public static func cashbackPercentageText(_ value: String) -> String {
		String(format: NSLocalizedString("cashback_percentage_text", bundle: .module, comment: ""), value)
	}
	public static func discountCoinText(_ value: String) -> String {
		String(format: NSLocalizedString("discount_coin_text", bundle: .module, comment: ""), value)
	}
	public static func discountPriceText(_ value: String) -> String {
		String(format: NSLocalizedString("discount_price_text", bundle: .module, comment: ""), value)
	}
	public static func discountPercentageText(_ value: String) -> String {
		String(format: NSLocalizedString("discount_percentage_text", bundle: .module, comment: ""), value)
	}
}
