//
//  Login.swift
//  DinotisApp
//
//  Created by Gus Adi on 15/09/21.
//

import Foundation

struct LoginBody: Codable {
	var phone: String
	var role: Int
	var password: String
}

struct LoginBodyV2: Codable {
	var phone: String
	var role: Int
	var password: String?
}

struct VerifyBody: Codable {
	var phone: String
	var otp: String
}

struct ResetPasswordBody: Codable {
	var phone: String
	var password: String
	var passwordConfirm: String
	var token: String
}

struct ForgetPasswordOtpResponse: Codable {
	let token: String?
	let expiresAt: String?
}

struct ChangePassword: Codable {
	var oldPassword: String?
	var password: String
	var confirmPassword: String
}

struct ChangePasswordOauth: Codable {
	var password: String
	var confirmPassword: String
}

struct LoginResponse: Codable {
	var accessToken: String
	var refreshToken: String
}

struct LoginResponseV2: Codable {
	let data: LoginResponseData?
	let token: LoginResponse?
}

struct LoginResponseData: Codable {
	let phone: String?
	let isDataFilled: Bool?
	let isPasswordFilled: Bool?
}

struct UnauthResponse: Codable, Error {
	let statusCode: Int?
	let message: String?
	var fields: [FieldError]?
	let error: String?
    let errorCode: Int?
}

struct FieldError: Codable {
	let itemId = UUID()
	let name: String?
	let error: String?
}

struct ResendOtp: Codable {
	var phone: String
}

struct ResendOTPChannel: Codable {
	var phone: String
	var channel: String = "whatsapp"
	var invitationCode: String? = nil
}

struct SuccessResponse: Codable {
	var message: String
}
