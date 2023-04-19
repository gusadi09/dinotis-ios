//
//  File.swift
//  
//
//  Created by Gus Adi on 16/01/23.
//

import Foundation
import Moya

public enum AuthenticationTargetType {
	case login(LoginRequest)
	case register(OTPRequest)
	case registrationOTPVerification(OTPVerificationRequest)
	case OTPVerification(OTPVerificationRequest)
	case refreshToken(String)
	case resendOtp(OTPRequest)
	case forgetPassword(OTPRequest)
	case forgetPasswordOTPVerification(OTPVerificationRequest)
	case resetPassword(ResetPasswordRequest)
	case changePassword(ChangePasswordRequest)
	case changePhone(OTPRequest)
	case changePhoneVerification(OTPVerificationRequest)
}

extension AuthenticationTargetType: DinotisTargetType, AccessTokenAuthorizable {
	public var authorizationType: AuthorizationType? {
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
		case .changePhoneVerification:
			return .bearer
		case .register:
			return .none
		case .registrationOTPVerification:
			return .none
		case .forgetPasswordOTPVerification:
			return .none
		case .resetPassword:
			return .bearer
		}
	}

	public var headers: [String: String]? {
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
		case .changePhoneVerification:
			return [:]
		case .register:
			return [:]
		case .registrationOTPVerification:
			return [:]
		case .forgetPasswordOTPVerification:
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
		case .changePhoneVerification:
			return JSONEncoding.default
		case .register:
			return JSONEncoding.default
		case .registrationOTPVerification:
			return JSONEncoding.default
		case .forgetPasswordOTPVerification:
			return JSONEncoding.default
		case .resetPassword:
			return JSONEncoding.default
		}
	}

	public var task: Task {
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
		case .changePhoneVerification(let body):
			return body.toJSON()
		case .register(let body):
			return body.toJSON()
		case .registrationOTPVerification(let body):
			return body.toJSON()
		case .forgetPasswordOTPVerification(let body):
			return body.toJSON()
		case .resetPassword(let body):
			return body.toJSON()
		}
	}

	public var path: String {
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
		case .changePhoneVerification:
			return "/users/phone/change/verify"
		case .register:
			return "/auth/register"
		case .registrationOTPVerification:
			return "/auth/otp/verify/register"
		case .forgetPasswordOTPVerification:
			return "/auth/password/otp/verify"
		case .resetPassword:
			return "/auth/password/verify"
		}
	}

	public var sampleData: Data {
		switch self {
		case .login(_):
			return LoginResponse.sampleData

		case .OTPVerification:
			return LoginTokenData.sampleData

		case .refreshToken:
			return LoginTokenData.sampleData

		case .resendOtp:
			return SuccessResponse.sampleData

		case .forgetPassword:
			return SuccessResponse.sampleData

		case .changePassword:
			return SuccessResponse.sampleData

		case .changePhone:
			return SuccessResponse.sampleData

		case .changePhoneVerification:
			return UserResponse.sampleData

		case .register:
			return SuccessResponse.sampleData
		case .registrationOTPVerification:
			return LoginResponse.sampleData
		case .forgetPasswordOTPVerification:
			return ForgetPasswordOTPResponse.sampleData
		case .resetPassword:
			return UserResponse.sampleData
		}
	}

	public var method:Moya.Method {
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
		case .changePhoneVerification:
			return .post
		case .register:
			return .post
		case .registrationOTPVerification:
			return .post
		case .forgetPasswordOTPVerification:
			return .post
		case .resetPassword:
			return .post
		}
	}
}
