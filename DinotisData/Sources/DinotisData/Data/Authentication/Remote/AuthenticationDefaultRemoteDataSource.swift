//
//  File.swift
//  
//
//  Created by Gus Adi on 19/01/23.
//

import Foundation
import Moya

public final class AuthenticationDefaultRemoteDataSource: AuthenticationRemoteDataSource {

	private let provider: MoyaProvider<AuthenticationTargetType>

	public init(provider: MoyaProvider<AuthenticationTargetType> = .defaultProvider()) {
		self.provider = provider
	}

	public func login(parameters: LoginRequest) async throws -> LoginResponse {
		try await provider.request(.login(parameters), model: LoginResponse.self)
	}

	public func register(params: OTPRequest) async throws -> SuccessResponse {
		try await provider.request(.register(params), model: SuccessResponse.self)
	}

	public func OTPRegisterVerification(params: OTPVerificationRequest) async throws -> LoginTokenData {
		try await provider.request(.registrationOTPVerification(params), model: LoginTokenData.self)
	}

	public func OTPVerification(params: OTPVerificationRequest) async throws -> LoginTokenData {
		try await provider.request(.OTPVerification(params), model: LoginTokenData.self)
	}

	public func refreshToken() async throws -> LoginTokenData {
		try await provider.request(.refreshToken(StateObservable.shared.refreshToken), model: LoginTokenData.self)
	}

	public func resendOTP(with email: OTPRequest) async throws -> SuccessResponse {
		try await provider.request(.resendOtp(email), model: SuccessResponse.self)
	}

	public func forgetPassword(params: OTPRequest) async throws -> SuccessResponse {
		try await provider.request(.forgetPassword(params), model: SuccessResponse.self)
	}

	public func OTPForgetPasswordVerification(params: OTPVerificationRequest) async throws -> ForgetPasswordOTPResponse {
		try await provider.request(.forgetPasswordOTPVerification(params), model: ForgetPasswordOTPResponse.self)
	}

	public func changePassword(params: ChangePasswordRequest) async throws -> SuccessResponse {
		try await provider.request(.changePassword(params), model: SuccessResponse.self)
	}

	public func resetPassword(params: ResetPasswordRequest) async throws -> UserResponse {
		try await provider.request(.resetPassword(params), model: UserResponse.self)
	}

	public func changePhone(phone: OTPRequest) async throws -> SuccessResponse {
		try await provider.request(.changePhone(phone), model: SuccessResponse.self)
	}

	public func changePhoneVerify(params: OTPVerificationRequest) async throws -> UserResponse {
		try await provider.request(.changePhoneVerification(params), model: UserResponse.self)
	}
}
