//
//  AuthenticationDefaultRepository.swift
//  DinotisApp
//
//  Created by Gus Adi on 14/02/22.
//

import Foundation
import Combine

final class AuthenticationDefaultRepository: AuthenticationRepository {
	
	private let localDataSource: AuthenticationLocalDataSource
	private let remoteDataSource: AuthenticationRemoteDataSource
	
	init(
		localDataSource: AuthenticationLocalDataSource = AuthenticationDefaultLocalDataSource(),
		remoteDataSource: AuthenticationRemoteDataSource = AuthenticationDefaultRemoteDataSource()
	) {
		self.remoteDataSource = remoteDataSource
		self.localDataSource = localDataSource
	}
	
	func saveToKeychain(_ value: String, forKey key: String) {
		localDataSource.saveToKeychain(value, forKey: key)
	}
	
	func loadFromKeychain(forKey key: String) -> String {
		localDataSource.loadFromKeychain(forKey: key)
	}
	
	func login(parameters: LoginBodyV2) -> AnyPublisher<LoginResponseV2, UnauthResponse> {
		remoteDataSource.login(parameters: parameters)
	}
	
	func register(params: ResendOTPChannel) -> AnyPublisher<SuccessResponse, UnauthResponse> {
		remoteDataSource.register(params: params)
	}
	
	func otpRegisterVerification(params: VerifyBody) -> AnyPublisher<LoginResponse, UnauthResponse> {
		remoteDataSource.otpRegisterVerification(params: params)
	}
	
	func otpVerification(params: VerifyBody) -> AnyPublisher<LoginResponse, UnauthResponse> {
		remoteDataSource.otpVerification(params: params)
	}
	
	func refreshToken(with refreshToken: String) -> AnyPublisher<LoginResponse, UnauthResponse> {
		remoteDataSource.refreshToken(with: refreshToken)
	}
	
	func resendOtp(with email: ResendOTPChannel) -> AnyPublisher<SuccessResponse, UnauthResponse> {
		remoteDataSource.resendOtp(with: email)
	}
	
	func forgetPassword(params: ResendOTPChannel) -> AnyPublisher<SuccessResponse, UnauthResponse> {
		remoteDataSource.forgetPassword(params: params)
	}
	
	func otpForgetPasswordVerification(params: VerifyBody) -> AnyPublisher<ForgetPasswordOtpResponse, UnauthResponse> {
		remoteDataSource.otpForgetPasswordVerification(params: params)
	}
	
	func changePassword(params: ChangePassword) -> AnyPublisher<SuccessResponse, UnauthResponse> {
		remoteDataSource.changePassword(params: params)
	}
	
	func resetPassword(params: ResetPasswordBody) -> AnyPublisher<Users, UnauthResponse> {
		remoteDataSource.resetPassword(params: params)
	}
	
	func changePhone(phone: ResendOTPChannel) -> AnyPublisher<SuccessResponse, UnauthResponse> {
		remoteDataSource.changePhone(phone: phone)
	}
	
	func changePhoneVerify(params: VerifyBody) -> AnyPublisher<Users, UnauthResponse> {
		remoteDataSource.changePhoneVerify(params: params)
	}
}
