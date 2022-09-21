//
//  AuthenticationDefaultRemoteDataSource.swift
//  DinotisApp
//
//  Created by Gus Adi on 14/02/22.
//

import Foundation
import Moya
import Combine

class AuthenticationDefaultRemoteDataSource: AuthenticationRemoteDataSource {
	
	private let provider: MoyaProvider<AuthenticationTargetType>
	
	init(provider: MoyaProvider<AuthenticationTargetType> = .defaultProvider()) {
		self.provider = provider
	}
	
	func register(params: ResendOTPChannel) -> AnyPublisher<SuccessResponse, UnauthResponse> {
		provider.request(.register(params), model: SuccessResponse.self)
	}
	
	func otpRegisterVerification(params: VerifyBody) -> AnyPublisher<LoginResponse, UnauthResponse> {
		provider.request(.registrationOTPVerify(params), model: LoginResponse.self)
	}
	
	func otpForgetPasswordVerification(params: VerifyBody) -> AnyPublisher<ForgetPasswordOtpResponse, UnauthResponse> {
		provider.request(.forgetPasswordOTPVerify(params), model: ForgetPasswordOtpResponse.self)
	}
	
	func resetPassword(params: ResetPasswordBody) -> AnyPublisher<Users, UnauthResponse> {
		provider.request(.resetPassword(params), model: Users.self)
	}
	
	func login(parameters: LoginBodyV2) -> AnyPublisher<LoginResponseV2, UnauthResponse> {
		provider.request(.login(parameters), model: LoginResponseV2.self)
	}
	
	func refreshToken(with refreshToken: String) -> AnyPublisher<LoginResponse, UnauthResponse> {
		provider.request(.refreshToken(refreshToken), model: LoginResponse.self)
	}
	
	func resendOtp(with phone: ResendOTPChannel) -> AnyPublisher<SuccessResponse, UnauthResponse> {
		provider.request(.resendOtp(phone), model: SuccessResponse.self)
	}
	
	func forgetPassword(params: ResendOTPChannel) -> AnyPublisher<SuccessResponse, UnauthResponse> {
		provider.request(.forgetPassword(params), model: SuccessResponse.self)
	}
	
	func changePassword(params: ChangePassword) -> AnyPublisher<SuccessResponse, UnauthResponse> {
		provider.request(.changePassword(params), model: SuccessResponse.self)
	}
	
	func changePhone(phone: ResendOTPChannel) -> AnyPublisher<SuccessResponse, UnauthResponse> {
		provider.request(.changePhone(phone), model: SuccessResponse.self)
	}
	
	func otpVerification(params: VerifyBody) -> AnyPublisher<LoginResponse, UnauthResponse> {
		provider.request(.OTPVerification(params), model: LoginResponse.self)
	}
	
	func changePhoneVerify(params: VerifyBody) -> AnyPublisher<Users, UnauthResponse> {
		provider.request(.changePhoneVerify(params), model: Users.self)
	}
}
