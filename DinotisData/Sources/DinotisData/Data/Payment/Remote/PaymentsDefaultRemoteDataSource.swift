//
//  File.swift
//  
//
//  Created by Garry on 02/02/23.
//

import Foundation
import Moya

public final class PaymentsDefaultRemoteDataSource: PaymentsRemoteDataSource {
    
    private let provider: MoyaProvider<PaymentsTargetType>
    
    public init(provider: MoyaProvider<PaymentsTargetType> = .defaultProvider()) {
        self.provider = provider
    }
    
    public func extraFee(body: PaymentExtraFeeRequest) async throws -> PaymentExtraFeeResponse {
        try await provider.request(.extraFee(body), model: PaymentExtraFeeResponse.self)
    }

	public func bookingPayment(body: BookingPaymentRequest) async throws -> UserBookingData {
		try await provider.request(.bookingPayment(body), model: UserBookingData.self)
	}

	public func coinPayment(body: CoinPaymentRequest) async throws -> UserBookingData {
		try await provider.request(.coinPayment(body), model: UserBookingData.self)
	}

	public func promoCodeChecking(body: PromoCodeRequest) async throws -> PromoCodeResponse {
		try await provider.request(.promoCodeChecking(body), model: PromoCodeResponse.self)
	}

	public func getPaymentMethod() async throws -> PaymentMethodResponse {
		try await provider.request(.getPaymentMethod, model: PaymentMethodResponse.self)
	}
}
