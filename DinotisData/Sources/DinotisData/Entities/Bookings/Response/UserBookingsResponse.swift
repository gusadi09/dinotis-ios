//
//  File.swift
//  
//
//  Created by Gus Adi on 01/02/23.
//

import Foundation

public struct UserBookingsResponse: Codable {
	public let data: [UserBookingData]?
	public let nextCursor: Int?

	public init(data: [UserBookingData]?, nextCursor: Int?) {
		self.data = data
		self.nextCursor = nextCursor
	}
}

public extension UserBookingsResponse {
	static var sample: UserBookingsResponse {
		UserBookingsResponse(
			data: [
				UserBookingData(
					id: "unittest",
					bookedAt: Date(),
					invoiceId: "DIN1234",
					canceledAt: Date(),
					doneAt: Date(),
					isFailed: false,
					meetingID: "unittestmeeting",
					userID: "unittestuser",
					createdAt: Date(),
					updatedAt: Date(),
					bookingPayment: BookingPaymentData(
						id: "unittestpayment",
						amount: "1000",
						paidAt: Date(),
						failedAt: Date(),
						bookingID: "unittestbooking",
						paymentMethodID: 0,
						externalId: "",
						redirectUrl: "",
						qrCodeUrl: "",
						paymentMethod: PaymentMethodData(
							id: 0,
							code: "DINO",
							name: "DINOTIS COIN",
							iconURL: "",
							extraFee: 0.0,
							extraFeeIsPercentage: false,
							bankID: 0,
							isEwallet: false,
							isDisbursement: false,
							isQr: false,
							isCC: false,
							isIap: true,
							isCoin: true,
							isActive: true,
							isVisible: true
						)
					),
					meeting: nil,
					meetingBundle: nil,
					status: ""
				)
			],
			nextCursor: nil
		)
	}

	static var sampleData: Data {
		UserBookingsResponse(
			data: [
				UserBookingData(
					id: "unittest",
					bookedAt: Date(),
					invoiceId: "DIN1234",
					canceledAt: Date(),
					doneAt: Date(),
					isFailed: false,
					meetingID: "unittestmeeting",
					userID: "unittestuser",
					createdAt: Date(),
					updatedAt: Date(),
					bookingPayment: BookingPaymentData(
						id: "unittestpayment",
						amount: "1000",
						paidAt: Date(),
						failedAt: Date(),
						bookingID: "unittestbooking",
						paymentMethodID: 0,
						externalId: "",
						redirectUrl: "",
						qrCodeUrl: "",
						paymentMethod: PaymentMethodData(
							id: 0,
							code: "DINO",
							name: "DINOTIS COIN",
							iconURL: "",
							extraFee: 0.0,
							extraFeeIsPercentage: false,
							bankID: 0,
							isEwallet: false,
							isDisbursement: false,
							isQr: false,
							isCC: false,
							isIap: true,
							isCoin: true,
							isActive: true,
							isVisible: true
						)
					),
					meeting: nil,
					meetingBundle: nil,
					status: ""
				)
			],
			nextCursor: nil
		).toJSONData()
	}
}

public struct UserBookingData: Codable, Identifiable {
	public let id: String?
	public let bookedAt: Date?
	public let invoiceId: String?
	public let canceledAt, doneAt: Date?
	public let isFailed: Bool?
	public let meetingID, userID: String?
	public let createdAt, updatedAt: Date?
	public let bookingPayment: BookingPaymentData?
	public let meeting: UserMeetingData?
	public let meetingBundle: BundlingData?
	public let status: String?

	public enum CodingKeys: String, CodingKey {
		case id, bookedAt, canceledAt, doneAt
		case meetingID = "meetingId"
		case userID = "userId"
		case invoiceId
		case createdAt, updatedAt, bookingPayment, meeting, isFailed, meetingBundle, status
	}

	public init(
		id: String? = nil,
		bookedAt: Date? = nil,
		invoiceId: String? = nil,
		canceledAt: Date? = nil,
		doneAt: Date? = nil,
		isFailed: Bool? = nil,
		meetingID: String? = nil,
		userID: String? = nil,
		createdAt: Date? = nil,
		updatedAt: Date? = nil,
		bookingPayment: BookingPaymentData? = nil,
		meeting: UserMeetingData? = nil,
		meetingBundle: BundlingData? = nil,
		status: String? = nil
	) {
		self.id = id
		self.bookedAt = bookedAt
		self.invoiceId = invoiceId
		self.canceledAt = canceledAt
		self.doneAt = doneAt
		self.isFailed = isFailed
		self.meetingID = meetingID
		self.userID = userID
		self.createdAt = createdAt
		self.updatedAt = updatedAt
		self.bookingPayment = bookingPayment
		self.meeting = meeting
		self.meetingBundle = meetingBundle
		self.status = status
	}
}

public extension UserBookingData {
	static var sample: UserBookingData {
		UserBookingData(
			id: "unittest",
			bookedAt: Date(),
			invoiceId: "DIN1234",
			canceledAt: Date(),
			doneAt: Date(),
			isFailed: false,
			meetingID: "unittestmeeting",
			userID: "unittestuser",
			createdAt: Date(),
			updatedAt: Date(),
			bookingPayment: BookingPaymentData(
				id: "unittestpayment",
				amount: "1000",
				paidAt: Date(),
				failedAt: Date(),
				bookingID: "unittestbooking",
				paymentMethodID: 0,
				externalId: "",
				redirectUrl: "",
				qrCodeUrl: "",
				paymentMethod: PaymentMethodData(
					id: 0,
					code: "DINO",
					name: "DINOTIS COIN",
					iconURL: "",
					extraFee: 0.0,
					extraFeeIsPercentage: false,
					bankID: 0,
					isEwallet: false,
					isDisbursement: false,
					isQr: false,
					isCC: false,
					isIap: true,
					isCoin: true,
					isActive: true,
					isVisible: true
				)
			),
			meeting: nil,
			meetingBundle: nil,
			status: ""
		)
	}

	static var sampleData: Data {
		UserBookingData(
			id: "unittest",
			bookedAt: Date(),
			invoiceId: "DIN1234",
			canceledAt: Date(),
			doneAt: Date(),
			isFailed: false,
			meetingID: "unittestmeeting",
			userID: "unittestuser",
			createdAt: Date(),
			updatedAt: Date(),
			bookingPayment: BookingPaymentData(
				id: "unittestpayment",
				amount: "1000",
				paidAt: Date(),
				failedAt: Date(),
				bookingID: "unittestbooking",
				paymentMethodID: 0,
				externalId: "",
				redirectUrl: "",
				qrCodeUrl: "",
				paymentMethod: PaymentMethodData(
					id: 0,
					code: "DINO",
					name: "DINOTIS COIN",
					iconURL: "",
					extraFee: 0.0,
					extraFeeIsPercentage: false,
					bankID: 0,
					isEwallet: false,
					isDisbursement: false,
					isQr: false,
					isCC: false,
					isIap: true,
					isCoin: true,
					isActive: true,
					isVisible: true
				)
			),
			meeting: nil,
			meetingBundle: nil,
			status: ""
		).toJSONData()
	}
}

public struct BookingPaymentData: Codable {
	public let id, amount: String?
	public let paidAt: Date?
	public let failedAt: Date?
	public let bookingID: String?
	public let paymentMethodID: Int?
	public let externalId: String?
	public let redirectUrl: String?
	public let qrCodeUrl: String?
	public let paymentMethod: PaymentMethodData?

	public enum CodingKeys: String, CodingKey {
		case id, amount, paidAt, failedAt
		case bookingID = "bookingId"
		case paymentMethodID = "paymentMethodId"
		case paymentMethod, redirectUrl, qrCodeUrl, externalId
	}

	public init(
		id: String?,
		amount: String?,
		paidAt: Date?,
		failedAt: Date?,
		bookingID: String?,
		paymentMethodID: Int?,
		externalId: String?,
		redirectUrl: String?,
		qrCodeUrl: String?,
		paymentMethod: PaymentMethodData?
	) {
		self.id = id
		self.amount = amount
		self.paidAt = paidAt
		self.failedAt = failedAt
		self.bookingID = bookingID
		self.paymentMethodID = paymentMethodID
		self.externalId = externalId
		self.redirectUrl = redirectUrl
		self.qrCodeUrl = qrCodeUrl
		self.paymentMethod = paymentMethod
	}
}

public struct BookedData: Codable {
	public let id: String?
	public let bookedAt: Date?
	public let canceledAt, doneAt: Date?
	public let meetingID, userID: String?
	public let createdAt, updatedAt: Date?
	public let bookingPayment: BookingPaymentData?
	public let user: UserResponse?

	public enum CodingKeys: String, CodingKey {
		case id, bookedAt, canceledAt, doneAt
		case meetingID = "meetingId"
		case userID = "userId"
		case createdAt, updatedAt, bookingPayment, user
	}

	public init(
		id: String?,
		bookedAt: Date?,
		canceledAt: Date?,
		doneAt: Date?,
		meetingID: String?,
		userID: String?,
		createdAt: Date?,
		updatedAt: Date?,
		bookingPayment: BookingPaymentData?,
		user: UserResponse?
	) {
		self.id = id
		self.bookedAt = bookedAt
		self.canceledAt = canceledAt
		self.doneAt = doneAt
		self.meetingID = meetingID
		self.userID = userID
		self.createdAt = createdAt
		self.updatedAt = updatedAt
		self.bookingPayment = bookingPayment
		self.user = user
	}
}
