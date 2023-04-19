//
//  File.swift
//  
//
//  Created by Garry on 02/02/23.
//

import Foundation

public struct PaymentExtraFeeResponse: Codable {
    public let extraFee: Int?
    
    public init(
        extraFee: Int?
    ) {
        self.extraFee = extraFee
    }
}

public extension PaymentExtraFeeResponse {
    static var sample: PaymentExtraFeeResponse {
        PaymentExtraFeeResponse(
            extraFee: 1000
        )
    }
    
    static var sampleData: Data {
        PaymentExtraFeeResponse(
            extraFee: 1000
        ).toJSONData()
    }
}

public struct PaymentMethodResponse: Codable {
	public let data: [PaymentMethodData]?

	public init(data: [PaymentMethodData]?) {
		self.data = data
	}
}

public struct PaymentMethodData: Codable {
	public let id: Int?
	public let code: String?
	public let name: String?
	public let iconURL: String?
	public let extraFee: Double?
	public let extraFeeIsPercentage: Bool?
	public let bankID: Int?
	public let isEwallet, isDisbursement, isQr, isCC, isIap, isCoin, isActive, isVisible: Bool?

	public enum CodingKeys: String, CodingKey {
		case id, code, name
		case iconURL = "iconUrl"
		case extraFee
		case bankID = "bankId"
		case isEwallet, isDisbursement, isQr, extraFeeIsPercentage, isCC, isIap, isCoin, isActive, isVisible
	}

	public init(
		id: Int?,
		code: String?,
		name: String?,
		iconURL: String?,
		extraFee: Double?,
		extraFeeIsPercentage: Bool?,
		bankID: Int?,
		isEwallet: Bool?,
		isDisbursement: Bool?,
		isQr: Bool?,
		isCC: Bool?,
		isIap: Bool?,
		isCoin: Bool?,
		isActive: Bool?,
		isVisible: Bool?
	) {
		self.id = id
		self.code = code
		self.name = name
		self.iconURL = iconURL
		self.extraFee = extraFee
		self.extraFeeIsPercentage = extraFeeIsPercentage
		self.bankID = bankID
		self.isEwallet = isEwallet
		self.isDisbursement = isDisbursement
		self.isQr = isQr
		self.isCC = isCC
		self.isIap = isIap
		self.isCoin = isCoin
		self.isActive = isActive
		self.isVisible = isVisible
	}
}

public extension PaymentMethodData {
	static var sample: PaymentMethodData {
		PaymentMethodData(
			id: 1,
			code: "BRIVA",
			name: "BRI Virtual Account",
			iconURL: "https://www.unittest.com",
			extraFee: 1000.0,
			extraFeeIsPercentage: false,
			bankID: 1,
			isEwallet: false,
			isDisbursement: false,
			isQr: false,
			isCC: false,
			isIap: false,
			isCoin: false,
			isActive: true,
			isVisible: true
		)
	}

	static var sampleData: Data {
		PaymentMethodData(
			id: 1,
			code: "BRIVA",
			name: "BRI Virtual Account",
			iconURL: "https://www.unittest.com",
			extraFee: 1000.0,
			extraFeeIsPercentage: false,
			bankID: 1,
			isEwallet: false,
			isDisbursement: false,
			isQr: false,
			isCC: false,
			isIap: false,
			isCoin: false,
			isActive: true,
			isVisible: true
		).toJSONData()
	}
}

public extension PaymentMethodResponse {
	static var sample: PaymentMethodResponse {
		PaymentMethodResponse(data: [PaymentMethodData.sample])
	}

	static var sampleData: Data {
		PaymentMethodResponse(data: [PaymentMethodData.sample]).toJSONData()
	}
}

public struct PromoCodeResponse: Codable {
	public let id: Int?
	public let code: String?
	public let amount: Int?
	public let cashbackAmount: Int?
	public let cashbackPercentageAmount: Int?
	public let percentageAmount: Int?
	public let title: String?
	public let description: String?
	public let isActive: Bool?
	public let bookingId: String?
	public let meetingId: String?
	public let paymentMethodId: Int?
	public let cashbackTotal: Int?
	public let discountTotal: Int?
	public let redeemedAt: Date?
	public let expiredAt: Date?
	public let createdAt: Date?
	public let updatedAt: Date?

	public init(
		id: Int?,
		code: String?,
		amount: Int?,
		cashbackAmount: Int?,
		cashbackPercentageAmount: Int?,
		percentageAmount: Int?,
		title: String?,
		description: String?,
		isActive: Bool?,
		bookingId: String?,
		meetingId: String?,
		paymentMethodId: Int?,
		cashbackTotal: Int?,
		discountTotal: Int?,
		redeemedAt: Date?,
		expiredAt: Date?,
		createdAt: Date?,
		updatedAt: Date?
	) {
		self.id = id
		self.code = code
		self.amount = amount
		self.cashbackAmount = cashbackAmount
		self.cashbackPercentageAmount = cashbackPercentageAmount
		self.percentageAmount = percentageAmount
		self.title = title
		self.description = description
		self.isActive = isActive
		self.bookingId = bookingId
		self.meetingId = meetingId
		self.paymentMethodId = paymentMethodId
		self.cashbackTotal = cashbackTotal
		self.discountTotal = discountTotal
		self.redeemedAt = redeemedAt
		self.expiredAt = expiredAt
		self.createdAt = createdAt
		self.updatedAt = updatedAt
	}
}

public extension PromoCodeResponse {
	static var sample: PromoCodeResponse {
		PromoCodeResponse(
			id: 1,
			code: "TYVY",
			amount: 1000,
			cashbackAmount: 0,
			cashbackPercentageAmount: 0,
			percentageAmount: 0,
			title: "Discount Test",
			description: "",
			isActive: true,
			bookingId: "unittestbookingid",
			meetingId: "unittestmeetingid",
			paymentMethodId: 1,
			cashbackTotal: 0,
			discountTotal: 1000,
			redeemedAt: Date(),
			expiredAt: Date(),
			createdAt: Date(),
			updatedAt: Date()
		)
	}

	static var sampleData: Data {
		PromoCodeResponse(
			id: 1,
			code: "TYVY",
			amount: 1000,
			cashbackAmount: 0,
			cashbackPercentageAmount: 0,
			percentageAmount: 0,
			title: "Discount Test",
			description: "",
			isActive: true,
			bookingId: "unittestbookingid",
			meetingId: "unittestmeetingid",
			paymentMethodId: 1,
			cashbackTotal: 0,
			discountTotal: 1000,
			redeemedAt: Date(),
			expiredAt: Date(),
			createdAt: Date(),
			updatedAt: Date()
		).toJSONData()
	}

	func defineDiscountString() -> [String] {
		var textArr = [String]()

		if self.percentageAmount.orZero() != 0 &&
			self.cashbackPercentageAmount.orZero() == 0 &&
			self.cashbackAmount.orZero() == 0 &&
			self.amount.orZero() == 0
		{
			textArr.append(LocalizationDataText.discountPercentageText("\(self.percentageAmount.orZero())"))
			return textArr

		} else if self.percentageAmount.orZero() == 0 &&
					self.cashbackPercentageAmount.orZero() == 0 &&
					self.cashbackAmount.orZero() == 0 &&
					self.amount.orZero() != 0
		{
			textArr.append(LocalizationDataText.discountPriceText("\(self.amount.orZero())".toCurrency()))
			return textArr
		} else if self.percentageAmount.orZero() == 0 &&
					self.cashbackPercentageAmount.orZero() != 0 &&
					self.cashbackAmount.orZero() == 0 &&
					self.amount.orZero() == 0
		{
			textArr.append(LocalizationDataText.cashbackPercentageText("\(self.cashbackPercentageAmount.orZero())"))
			return textArr
		} else if self.percentageAmount.orZero() == 0 &&
					self.cashbackPercentageAmount.orZero() == 0 &&
					self.cashbackAmount.orZero() != 0 &&
					self.amount.orZero() == 0
		{
			textArr.append(LocalizationDataText.cashbackCoinText("\(self.cashbackAmount.orZero())".toPriceFormat()))
			return textArr
		} else if self.percentageAmount.orZero() != 0 &&
					self.cashbackPercentageAmount.orZero() != 0 &&
					self.cashbackAmount.orZero() == 0 &&
					self.amount.orZero() == 0
		{
			textArr.append(LocalizationDataText.discountPercentageText("\(self.percentageAmount.orZero())"))
			textArr.append(LocalizationDataText.cashbackPercentageText("\(self.cashbackPercentageAmount.orZero())"))
			return textArr
		} else if self.percentageAmount.orZero() == 0 &&
					self.cashbackPercentageAmount.orZero() == 0 &&
					self.cashbackAmount.orZero() != 0 &&
					self.amount.orZero() != 0 {
			textArr.append(LocalizationDataText.discountPriceText("\(self.amount.orZero())".toCurrency()))
			textArr.append(LocalizationDataText.cashbackCoinText("\(self.cashbackAmount.orZero())".toPriceFormat()))
			return textArr
		} else if self.percentageAmount.orZero() != 0 &&
					self.cashbackPercentageAmount.orZero() == 0 &&
					self.cashbackAmount.orZero() != 0 &&
					self.amount.orZero() == 0 {
			textArr.append(LocalizationDataText.discountPercentageText("\(self.percentageAmount.orZero())"))
			textArr.append(LocalizationDataText.cashbackCoinText("\(self.cashbackAmount.orZero())".toPriceFormat()))
			return textArr
		} else if self.percentageAmount.orZero() != 0 &&
					self.cashbackPercentageAmount.orZero() == 0 &&
					self.cashbackAmount.orZero() == 0 &&
					self.amount.orZero() != 0 {
			textArr.append(LocalizationDataText.discountPercentageText("\(self.percentageAmount.orZero())"))
			textArr.append(LocalizationDataText.discountPriceText("\(self.amount.orZero())".toCurrency()))
			return textArr
		} else if self.percentageAmount.orZero() == 0 &&
					self.cashbackPercentageAmount.orZero() != 0 &&
					self.cashbackAmount.orZero() != 0 &&
					self.amount.orZero() == 0 {
			textArr.append(LocalizationDataText.cashbackPercentageText("\(self.cashbackPercentageAmount.orZero())"))
			textArr.append(LocalizationDataText.cashbackCoinText("\(self.cashbackAmount.orZero())".toPriceFormat()))
			return textArr
		} else if self.percentageAmount.orZero() == 0 &&
					self.cashbackPercentageAmount.orZero() != 0 &&
					self.cashbackAmount.orZero() == 0 &&
					self.amount.orZero() != 0 {
			textArr.append(LocalizationDataText.cashbackPercentageText("\(self.cashbackPercentageAmount.orZero())"))
			textArr.append(LocalizationDataText.discountPriceText("\(self.amount.orZero())".toCurrency()))
			return textArr
		} else if self.percentageAmount.orZero() == 0 &&
					self.cashbackPercentageAmount.orZero() != 0 &&
					self.cashbackAmount.orZero() != 0 &&
					self.amount.orZero() != 0 {
			textArr.append(LocalizationDataText.cashbackPercentageText("\(self.cashbackPercentageAmount.orZero())"))
			textArr.append(LocalizationDataText.cashbackCoinText("\(self.cashbackAmount.orZero())".toPriceFormat()))
			textArr.append(LocalizationDataText.discountPriceText("\(self.amount.orZero())".toCurrency()))
			return textArr
		} else if self.percentageAmount.orZero() != 0 &&
					self.cashbackPercentageAmount.orZero() == 0 &&
					self.cashbackAmount.orZero() != 0 &&
					self.amount.orZero() != 0 {
			textArr.append(LocalizationDataText.discountPercentageText("\(self.percentageAmount.orZero())"))
			textArr.append(LocalizationDataText.cashbackCoinText("\(self.cashbackAmount.orZero())".toPriceFormat()))
			textArr.append(LocalizationDataText.discountPriceText("\(self.amount.orZero())".toCurrency()))
			return textArr
		} else if self.percentageAmount.orZero() != 0 &&
					self.cashbackPercentageAmount.orZero() != 0 &&
					self.cashbackAmount.orZero() == 0 &&
					self.amount.orZero() != 0 {
			textArr.append(LocalizationDataText.discountPercentageText("\(self.percentageAmount.orZero())"))
			textArr.append(LocalizationDataText.cashbackPercentageText("\(self.cashbackPercentageAmount.orZero())"))
			textArr.append(LocalizationDataText.discountPriceText("\(self.amount.orZero())".toCurrency()))
			return textArr
		} else if self.percentageAmount.orZero() != 0 &&
					self.cashbackPercentageAmount.orZero() != 0 &&
					self.cashbackAmount.orZero() != 0 &&
					self.amount.orZero() == 0 {
			textArr.append(LocalizationDataText.discountPercentageText("\(self.percentageAmount.orZero())"))
			textArr.append(LocalizationDataText.cashbackPercentageText("\(self.cashbackPercentageAmount.orZero())"))
			textArr.append(LocalizationDataText.cashbackCoinText("\(self.cashbackAmount.orZero())".toPriceFormat()))
			return textArr
		} else {
			textArr.append(LocalizationDataText.discountPercentageText("\(self.percentageAmount.orZero())"))
			textArr.append(LocalizationDataText.cashbackPercentageText("\(self.cashbackPercentageAmount.orZero())"))
			textArr.append(LocalizationDataText.cashbackCoinText("\(self.cashbackAmount.orZero())".toPriceFormat()))
			textArr.append(LocalizationDataText.discountPriceText("\(self.amount.orZero())".toCurrency()))
			return textArr
		}
	}
}
