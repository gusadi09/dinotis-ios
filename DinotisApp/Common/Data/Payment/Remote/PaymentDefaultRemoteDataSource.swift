//
//  PaymentDefaultRemoteDataSource.swift
//  DinotisApp
//
//  Created by Gus Adi on 14/03/22.
//

import Foundation
import Moya
import Combine

final class PaymentDefaultRemoteDataSource: PaymentRemoteDataSource {
	
	private let provider: MoyaProvider<PaymentTargetType>
	
	init(provider: MoyaProvider<PaymentTargetType> = .defaultProvider()) {
		self.provider = provider
	}
	
	func getPaymentMethod() -> AnyPublisher<PaymentMethodResponse, UnauthResponse> {
		self.provider.request(.getPaymentMethod, model: PaymentMethodResponse.self)
	}
	
	func sendPayment(params: BookingPay) -> AnyPublisher<BookingData, UnauthResponse> {
		self.provider.request(.payBooking(params), model: BookingData.self)
	}
	
	func extraFee(meetingId: String) -> AnyPublisher<ExtraFeeResponse, UnauthResponse> {
		self.provider.request(.extraFee(meetingId), model: ExtraFeeResponse.self)
	}

	func checkPromoCode(params: PromoCodeBody) -> AnyPublisher<PromoCodeResponse, UnauthResponse> {
		self.provider.request(.promoCodeCheck(params), model: PromoCodeResponse.self)
	}

	func sendPaymentCoin(params: CoinPay) -> AnyPublisher<BookingData, UnauthResponse> {
		self.provider.request(.payWithCoin(params), model: BookingData.self)
	}
}
