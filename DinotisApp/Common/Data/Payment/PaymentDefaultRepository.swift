//
//  PaymentDefaultRepository.swift
//  DinotisApp
//
//  Created by Gus Adi on 14/03/22.
//

import Foundation
import Combine

final class PaymentDefaultRepository: PaymentRepository {

	private let remote: PaymentRemoteDataSource
	
	init(remote: PaymentRemoteDataSource = PaymentDefaultRemoteDataSource()) {
		self.remote = remote
	}
	
	func provideGetPaymentMethod() -> AnyPublisher<PaymentMethodResponse, UnauthResponse> {
		self.remote.getPaymentMethod()
	}
	
	func provideSendBookingPayment(by params: BookingPay) -> AnyPublisher<BookingData, UnauthResponse> {
		self.remote.sendPayment(params: params)
	}
	
	func provideExtraFee(with meetingId: String) -> AnyPublisher<ExtraFeeResponse, UnauthResponse> {
		self.remote.extraFee(meetingId: meetingId)
	}

	func provideCheckPromoCode(by params: PromoCodeBody) -> AnyPublisher<PromoCodeResponse, UnauthResponse> {
		self.remote.checkPromoCode(params: params)
	}

	func provideSendPaymentCoin(by params: CoinPay) -> AnyPublisher<BookingData, UnauthResponse> {
		self.remote.sendPaymentCoin(params: params)
	}
}
