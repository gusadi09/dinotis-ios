//
//  File.swift
//  
//
//  Created by Gus Adi on 19/01/23.
//

import Foundation

public protocol AuthenticationRemoteDataSource {
	func login(parameters: LoginRequest) async throws -> LoginResponse
	func register(params: OTPRequest) async throws -> SuccessResponse
	func OTPRegisterVerification(params: OTPVerificationRequest) async throws -> LoginTokenData
	func OTPVerification(params: OTPVerificationRequest) async throws -> LoginTokenData
	func refreshToken() async throws -> LoginTokenData
	func resendOTP(with email: OTPRequest) async throws -> SuccessResponse
	func forgetPassword(params: OTPRequest) async throws -> SuccessResponse
	func OTPForgetPasswordVerification(params: OTPVerificationRequest) async throws -> ForgetPasswordOTPResponse
	func changePassword(params: ChangePasswordRequest) async throws -> SuccessResponse
	func resetPassword(params: ResetPasswordRequest) async throws -> UserResponse
	func changePhone(phone: OTPRequest) async throws -> SuccessResponse
	func changePhoneVerify(params: OTPVerificationRequest) async throws -> UserResponse
}
