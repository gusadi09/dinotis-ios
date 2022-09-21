//
//  AuthenticationTargetType.swift
//  DinotisApp
//
//  Created by Gus Adi on 14/02/22.
//

import Foundation
import Moya

enum AuthenticationTargetType {
	case login(LoginBodyV2)
	case register(ResendOTPChannel)
	case registrationOTPVerify(VerifyBody)
	case OTPVerification(VerifyBody)
	case refreshToken(String)
	case resendOtp(ResendOTPChannel)
	case forgetPassword(ResendOTPChannel)
	case forgetPasswordOTPVerify(VerifyBody)
	case resetPassword(ResetPasswordBody)
	case changePassword(ChangePassword)
	case changePhone(ResendOTPChannel)
	case changePhoneVerify(VerifyBody)
}

extension AuthenticationTargetType: DinotisTargetType, AccessTokenAuthorizable {
	var authorizationType: AuthorizationType? {
		switch self {
		case .login:
			return .none
		case .refreshToken:
			return .none
		case .resendOtp:
			return .none
		case .forgetPassword:
			return .none
		case .changePassword:
			return .bearer
		case .changePhone:
			return .bearer
		case .OTPVerification:
			return .none
		case .changePhoneVerify:
			return .bearer
		case .register:
			return .none
		case .registrationOTPVerify:
			return .none
		case .forgetPasswordOTPVerify:
			return .none
		case .resetPassword:
			return .bearer
		}
	}
	
	var headers: [String: String]? {
		switch self {
		case .login:
			return [:]
		case .refreshToken(let refreshToken):
			return ["Authorization": "Bearer \(refreshToken)"]
		case .resendOtp:
			return [:]
		case .forgetPassword:
			return [:]
		case .changePassword:
			return [:]
		case .changePhone:
			return [:]
		case .OTPVerification:
			return [:]
		case .changePhoneVerify:
			return [:]
		case .register:
			return [:]
		case .registrationOTPVerify:
			return [:]
		case .forgetPasswordOTPVerify:
			return [:]
		case .resetPassword:
			return [:]
		}
	}
	
	var parameterEncoding: Moya.ParameterEncoding {
		switch self {
		case .login:
			return JSONEncoding.default
		case .refreshToken:
			return URLEncoding.default
		case .resendOtp:
			return JSONEncoding.default
		case .forgetPassword:
			return JSONEncoding.default
		case .changePassword:
			return JSONEncoding.default
		case .changePhone:
			return JSONEncoding.default
		case .OTPVerification:
			return JSONEncoding.default
		case .changePhoneVerify:
			return JSONEncoding.default
		case .register:
			return JSONEncoding.default
		case .registrationOTPVerify:
			return JSONEncoding.default
		case .forgetPasswordOTPVerify:
			return JSONEncoding.default
		case .resetPassword:
			return JSONEncoding.default
		}
	}
	
	var task: Task {
		return .requestParameters(parameters: parameters, encoding: parameterEncoding)
	}
	
	var parameters: [String : Any] {
		switch self {
		case .login(let loginForm):
			return loginForm.toJSON()
		case .refreshToken:
			return [:]
		case .resendOtp(let resend):
			return resend.toJSON()
		case .forgetPassword(let forgetPassword):
			return forgetPassword.toJSON()
		case .changePassword(let changePassword):
			return changePassword.toJSON()
		case .changePhone(let phoneNumber):
			return phoneNumber.toJSON()
		case .OTPVerification(let body):
			return body.toJSON()
		case .changePhoneVerify(let body):
			return body.toJSON()
		case .register(let body):
			return body.toJSON()
		case .registrationOTPVerify(let body):
			return body.toJSON()
		case .forgetPasswordOTPVerify(let body):
			return body.toJSON()
		case .resetPassword(let body):
			return body.toJSON()
		}
	}
	
	var path: String {
		switch self {
		case .login:
			return "/auth/login"
		case .refreshToken:
			return "/auth/refresh"
		case .resendOtp:
			return "/auth/otp/resend"
		case .forgetPassword:
			return "/auth/password/phone"
		case .changePassword:
			return "/users/password"
		case .changePhone:
			return "/users/phone"
		case .OTPVerification:
			return "/auth/otp/verify"
		case .changePhoneVerify:
			return "/users/phone/change/verify"
		case .register:
			return "/auth/register"
		case .registrationOTPVerify:
			return "/auth/otp/verify/register"
		case .forgetPasswordOTPVerify:
			return "/auth/password/otp/verify"
		case .resetPassword:
			return "/auth/password/verify"
		}
	}
	
	var sampleData: Data {
		switch self {
		case .login(let params):
			if params.password == nil {
				let params = LoginResponseV2(
					data: LoginResponseData(
						phone: "787897997",
						isDataFilled: true,
						isPasswordFilled: false
					),
					token: nil
				).toJSONData()
				return params
			} else {
				let params = LoginResponseV2(
					data: LoginResponseData(
						phone: "787897997",
						isDataFilled: true,
						isPasswordFilled: true
					),
					token: LoginResponse(
						accessToken: "676tu7gyut7",
						refreshToken: "y787tg7iug8o9"
					)
				).toJSONData()
				return params
			}
			
		case .OTPVerification:
			let params = LoginResponse(accessToken: "testing", refreshToken: "testing").toJSONData()
			return params
			
		case .refreshToken:
			let params = LoginResponse(accessToken: "testing", refreshToken: "testing").toJSONData()
			return params
			
		case .resendOtp:
			return Data()
			
		case .forgetPassword:
			return Data()
			
		case .changePassword:
			return Data()
			
		case .changePhone:
			return Data()
			
		case .changePhoneVerify:
			let params = Users(
				id: "3434b3hb3j334",
				email: "test@gmail.com",
				name: "Testing Account",
				username: "testing99",
				phone: "+62856783234334",
				profilePhoto: nil,
				profileDescription: nil,
				emailVerifiedAt: nil,
				isVerified: nil,
				isPasswordFilled: nil,
				registeredWith: nil,
				lastLoginAt: nil,
				professionID: nil,
				createdAt: nil,
				updatedAt: nil,
				roles: [],
				balance: nil,
				profession: nil,
				professions: [],
				calendar: nil,
				userHighlights: [],
				coinBalance: nil
			).toJSONData()
			
			return params
			
		case .register:
			return Data()
		case .registrationOTPVerify:
			return Data()
		case .forgetPasswordOTPVerify:
			let response = ForgetPasswordOtpResponse(token: "test", expiresAt: Date().toString(format: .utc))
			return response.toJSONData()
		case .resetPassword:
			return Data()
		}
	}
	
	var method:Moya.Method {
		switch self {
		case .login:
			return .post
		case .refreshToken:
			return .post
		case .resendOtp:
			return .post
		case .forgetPassword:
			return .post
		case .changePassword:
			return .put
		case .changePhone:
			return .patch
		case .OTPVerification:
			return .post
		case .changePhoneVerify:
			return .post
		case .register:
			return .post
		case .registrationOTPVerify:
			return .post
		case .forgetPasswordOTPVerify:
			return .post
		case .resetPassword:
			return .post
		}
	}
}
