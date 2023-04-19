//
//  File.swift
//  
//
//  Created by Gus Adi on 19/01/23.
//

import Foundation

public final class AuthenticationDefaultRepository: AuthenticationRepository {

	private let remote: AuthenticationRemoteDataSource
	private let local: AuthenticationLocalDataSource

	public init(
		remote: AuthenticationRemoteDataSource = AuthenticationDefaultRemoteDataSource(),
		local: AuthenticationLocalDataSource = AuthenticationDefaultLocalDataSource()
	) {
		self.remote = remote
		self.local = local
	}

	public func saveToKeychain(_ value: String, forKey key: String) async {
		await local.saveToKeychain(value, forKey: key)
	}

	public func loadFromKeychain(forKey key: String) async -> String {
		await local.loadFromKeychain(forKey: key)
	}

	public func login(with parameters: LoginRequest) async throws -> LoginResponse {
		try await remote.login(parameters: parameters)
	}

	public func register(with params: OTPRequest) async throws -> SuccessResponse {
		try await remote.register(params: params)
	}

	public func OTPRegisterVerification(by params: OTPVerificationRequest) async throws -> LoginTokenData {
		try await remote.OTPRegisterVerification(params: params)
	}

	public func OTPVerification(with params: OTPVerificationRequest) async throws -> LoginTokenData {
		try await remote.OTPVerification(params: params)
	}

	public func refreshToken() async throws -> LoginTokenData {
		try await remote.refreshToken()
	}

	public func resendOTP(with email: OTPRequest) async throws -> SuccessResponse {
		try await remote.resendOTP(with: email)
	}

	public func forgetPassword(by params: OTPRequest) async throws -> SuccessResponse {
		try await remote.forgetPassword(params: params)
	}

	public func OTPForgetPasswordVerification(with params: OTPVerificationRequest) async throws -> ForgetPasswordOTPResponse {
		try await remote.OTPForgetPasswordVerification(params: params)
	}

	public func changePassword(with params: ChangePasswordRequest) async throws -> SuccessResponse {
		try await remote.changePassword(params: params)
	}

	public func resetPassword(with params: ResetPasswordRequest) async throws -> UserResponse {
		try await remote.resetPassword(params: params)
	}

	public func changePhone(with phone: OTPRequest) async throws -> SuccessResponse {
		try await remote.changePhone(phone: phone)
	}

	public func changePhoneVerification(by params: OTPVerificationRequest) async throws -> UserResponse {
		try await remote.changePhoneVerify(params: params)
	}
}
