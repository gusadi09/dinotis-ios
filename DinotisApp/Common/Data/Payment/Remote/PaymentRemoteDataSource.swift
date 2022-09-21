//
//  PaymentRemoteDataSource.swift
//  DinotisApp
//
//  Created by Gus Adi on 14/03/22.
//

import Foundation
import Combine

protocol PaymentRemoteDataSource {
	func getPaymentMethod() -> AnyPublisher<PaymentMethodResponse, UnauthResponse>
	func sendPayment(params: BookingPay) -> AnyPublisher<BookingData, UnauthResponse>
	func sendPaymentCoin(params: CoinPay) -> AnyPublisher<BookingData, UnauthResponse>
	func extraFee(meetingId: String) -> AnyPublisher<ExtraFeeResponse, UnauthResponse>
	func checkPromoCode(params: PromoCodeBody) -> AnyPublisher<PromoCodeResponse, UnauthResponse>
}
