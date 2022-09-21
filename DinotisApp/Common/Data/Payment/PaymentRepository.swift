//
//  PaymentRepository.swift
//  DinotisApp
//
//  Created by Gus Adi on 14/03/22.
//

import Foundation
import Combine

protocol PaymentRepository {
	func provideGetPaymentMethod() -> AnyPublisher<PaymentMethodResponse, UnauthResponse>
	func provideSendBookingPayment(by params: BookingPay) -> AnyPublisher<BookingData, UnauthResponse>
	func provideSendPaymentCoin(by params: CoinPay) -> AnyPublisher<BookingData, UnauthResponse>
	func provideExtraFee(with meetingId: String) -> AnyPublisher<ExtraFeeResponse, UnauthResponse>
	func provideCheckPromoCode(by params: PromoCodeBody) -> AnyPublisher<PromoCodeResponse, UnauthResponse>
}
