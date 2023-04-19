//
//  File.swift
//  
//
//  Created by Gus Adi on 19/01/23.
//

import Foundation

public protocol AuthenticationRepository {
	func saveToKeychain(_ value: String, forKey key: String) async
	func loadFromKeychain(forKey key: String) async -> String
	func login(with parameters: LoginRequest) async throws -> LoginResponse
	func register(with params: OTPRequest) async throws -> SuccessResponse
	func OTPRegisterVerification(by params: OTPVerificationRequest) async throws -> LoginTokenData
	func OTPVerification(with params: OTPVerificationRequest) async throws -> LoginTokenData
	func refreshToken() async throws -> LoginTokenData
	func resendOTP(with email: OTPRequest) async throws -> SuccessResponse
	func forgetPassword(by params: OTPRequest) async throws -> SuccessResponse
	func OTPForgetPasswordVerification(with params: OTPVerificationRequest) async throws -> ForgetPasswordOTPResponse
	func changePassword(with params: ChangePasswordRequest) async throws -> SuccessResponse
	func resetPassword(with params: ResetPasswordRequest) async throws -> UserResponse
	func changePhone(with phone: OTPRequest) async throws -> SuccessResponse
	func changePhoneVerification(by params: OTPVerificationRequest) async throws -> UserResponse
}
