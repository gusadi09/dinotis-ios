//
//  File.swift
//  
//
//  Created by Garry on 02/02/23.
//

import Foundation

public protocol PaymentsRemoteDataSource {
    func extraFee(body: PaymentExtraFeeRequest) async throws -> PaymentExtraFeeResponse
	func bookingPayment(body: BookingPaymentRequest) async throws -> UserBookingData
	func coinPayment(body: CoinPaymentRequest) async throws -> UserBookingData
	func promoCodeChecking(body: PromoCodeRequest) async throws -> PromoCodeResponse
	func getPaymentMethod() async throws -> PaymentMethodResponse
}
