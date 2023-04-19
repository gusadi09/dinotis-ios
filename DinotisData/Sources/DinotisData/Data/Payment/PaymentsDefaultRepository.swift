//
//  File.swift
//  
//
//  Created by Garry on 02/02/23.
//

import Foundation

public final class PaymentsDefaultRepository: PaymentsRepository {
    
    private let remote: PaymentsRemoteDataSource
    
    public init(remote: PaymentsRemoteDataSource = PaymentsDefaultRemoteDataSource()) {
        self.remote = remote
    }
    
    public func provideExtraFee(body: PaymentExtraFeeRequest) async throws -> PaymentExtraFeeResponse {
        try await self.remote.extraFee(body: body)
    }

	public func provideBookingPayment(body: BookingPaymentRequest) async throws -> UserBookingData {
		try await self.remote.bookingPayment(body: body)
	}

	public func provideCoinPayment(body: CoinPaymentRequest) async throws -> UserBookingData {
		try await self.remote.coinPayment(body: body)
	}

	public func providePromoCodeChecking(body: PromoCodeRequest) async throws -> PromoCodeResponse {
		try await self.remote.promoCodeChecking(body: body)
	}

	public func provideGetPaymentMethod() async throws -> PaymentMethodResponse {
		try await self.remote.getPaymentMethod()
	}
}
