//
//  File.swift
//  
//
//  Created by Gus Adi on 01/02/23.
//

import Foundation

public struct PaymentExtraFeeRequest: Codable {
    public var meetingId: String?
    public var meetingBundleId: String?
    public var rateCardId: String?
    
    public init(
        meetingId: String? = "",
        meetingBundleId: String? = "",
        rateCardId: String? = ""
    ) {
        self.meetingId = meetingId
        self.meetingBundleId = meetingBundleId
        self.rateCardId = rateCardId
    }
}

public extension PaymentExtraFeeRequest {
    static var sample: PaymentExtraFeeRequest {
		PaymentExtraFeeRequest(
            meetingId: "testmeetingid",
            meetingBundleId: "testbundleid",
            rateCardId: "testratecardid"
        )
    }
    
    static var sampleData: Data {
		PaymentExtraFeeRequest(
            meetingId: "testmeetingid",
            meetingBundleId: "testbundleid",
            rateCardId: "testratecardid"
        ).toJSONData()
    }
}

public struct BookingPaymentRequest: Codable {
	public var paymentMethod: Int?
	public var meetingId: String?
	public var voucherCode: String?
	public var meetingBundleId: String?
	public var rateCardId: String?

	public init(
		paymentMethod: Int? = nil,
		meetingId: String? = nil,
		voucherCode: String? = nil,
		meetingBundleId: String? = nil,
		rateCardId: String? = nil
	) {
		self.paymentMethod = paymentMethod
		self.meetingId = meetingId
		self.voucherCode = voucherCode
		self.meetingBundleId = meetingBundleId
		self.rateCardId = rateCardId
	}
}

public struct CoinPaymentRequest: Codable {
	public var meetingId: String?
	public var voucherCode: String?
	public var meetingBundleId: String?

	public init(meetingId: String? = nil, voucherCode: String? = nil, meetingBundleId: String? = nil) {
		self.meetingId = meetingId
		self.voucherCode = voucherCode
		self.meetingBundleId = meetingBundleId
	}
}

public struct PromoCodeRequest: Codable {
	public let code: String?
	public let meetingId: String?
	public let paymentMethodId: Int?

	public init(code: String?, meetingId: String?, paymentMethodId: Int?) {
		self.code = code
		self.meetingId = meetingId
		self.paymentMethodId = paymentMethodId
	}
}
