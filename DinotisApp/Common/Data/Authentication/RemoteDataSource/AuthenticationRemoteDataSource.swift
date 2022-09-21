//
//  AuthenticationRemoteDataSource.swift
//  DinotisApp
//
//  Created by Gus Adi on 14/02/22.
//

import Foundation
import Combine

protocol AuthenticationRemoteDataSource {
	func login(parameters: LoginBodyV2) -> AnyPublisher<LoginResponseV2, UnauthResponse>
	func register(params: ResendOTPChannel) -> AnyPublisher<SuccessResponse, UnauthResponse>
	func otpRegisterVerification(params: VerifyBody) -> AnyPublisher<LoginResponse, UnauthResponse>
	func otpVerification(params: VerifyBody) -> AnyPublisher<LoginResponse, UnauthResponse>
	func refreshToken(with refreshToken: String) -> AnyPublisher<LoginResponse, UnauthResponse>
	func resendOtp(with email: ResendOTPChannel) -> AnyPublisher<SuccessResponse, UnauthResponse>
	func forgetPassword(params: ResendOTPChannel) -> AnyPublisher<SuccessResponse, UnauthResponse>
	func otpForgetPasswordVerification(params: VerifyBody) -> AnyPublisher<ForgetPasswordOtpResponse, UnauthResponse>
	func changePassword(params: ChangePassword) -> AnyPublisher<SuccessResponse, UnauthResponse>
	func resetPassword(params: ResetPasswordBody) -> AnyPublisher<Users, UnauthResponse>
	func changePhone(phone: ResendOTPChannel) -> AnyPublisher<SuccessResponse, UnauthResponse>
	func changePhoneVerify(params: VerifyBody) -> AnyPublisher<Users, UnauthResponse>
}
