//
//  File.swift
//  
//
//  Created by Garry on 02/02/23.
//

import Foundation

public protocol PaymentsRepository {
    func provideExtraFee(body: PaymentExtraFeeRequest) async throws -> PaymentExtraFeeResponse
	func provideBookingPayment(body: BookingPaymentRequest) async throws -> UserBookingData
	func provideCoinPayment(body: CoinPaymentRequest) async throws -> UserBookingData
	func providePromoCodeChecking(body: PromoCodeRequest) async throws -> PromoCodeResponse
	func provideGetPaymentMethod() async throws -> PaymentMethodResponse
}
