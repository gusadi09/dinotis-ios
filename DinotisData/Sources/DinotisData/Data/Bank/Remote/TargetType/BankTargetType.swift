//
//  BankTargetType.swift
//  DinotisApp
//
//  Created by Gus Adi on 07/11/22.
//

import Foundation
import Moya

public enum BankTargetType {
	case getBankAccount
	case addBankAccount(AddBankAccountRequest)
	case editBankAccount(Int, AddBankAccountRequest)
	case getBankAccountDetail(Int)
	case withdrawBalance(WithdrawalRequest)
	case withdrawTranscationDetail(String)
	case getTransactionHistory
	case getWithdrawBankList
}

extension BankTargetType: DinotisTargetType, AccessTokenAuthorizable {
	var parameters: [String : Any] {
		switch self {
		case .getBankAccount:
			return [:]
		case .getBankAccountDetail(_):
			return [:]
		case .withdrawBalance(let body):
			return body.toJSON()
		case .withdrawTranscationDetail(_):
			return [:]
		case .getTransactionHistory:
			return [:]
		case .addBankAccount(let body):
			return body.toJSON()
		case .editBankAccount(_, let body):
			return body.toJSON()
		case .getWithdrawBankList:
			return [:]
		}
	}

    public var authorizationType: AuthorizationType? {
		return .bearer
	}

	var parameterEncoding: Moya.ParameterEncoding {
		switch self {
		case .getBankAccount:
			return URLEncoding.default
		case .addBankAccount(_):
			return JSONEncoding.default
		case .editBankAccount(_, _):
			return JSONEncoding.default
		case .getBankAccountDetail(_):
			return URLEncoding.default
		case .withdrawBalance(_):
			return JSONEncoding.default
		case .withdrawTranscationDetail(_):
			return URLEncoding.default
		case .getTransactionHistory:
			return URLEncoding.default
		case .getWithdrawBankList:
			return URLEncoding.default
		}
	}

    public var task: Task {
		return .requestParameters(parameters: parameters, encoding: parameterEncoding)
	}

    public var path: String {
		switch self {
		case .getBankAccount:
			return "/bank-accounts"
		case .getBankAccountDetail(let id):
			return "/bank-accounts/\(id)"
		case .withdrawBalance:
			return "/withdraws"
		case .withdrawTranscationDetail(let withdrawId):
			return "/withdraws/\(withdrawId)"
		case .getTransactionHistory:
			return "/balances/user/details"
		case .addBankAccount(_):
			return "/bank-accounts"
		case .editBankAccount(let id, _):
			return "/bank-accounts/\(id)"
		case .getWithdrawBankList:
			return "/banks"
		}
	}

    public var method: Moya.Method {
		switch self {
		case .getBankAccount:
			return .get
		case .addBankAccount(_):
			return .post
		case .editBankAccount(_, _):
			return .put
		case .getBankAccountDetail(_):
			return .get
		case .withdrawBalance(_):
			return .post
		case .withdrawTranscationDetail(_):
			return .get
		case .getTransactionHistory:
			return .get
		case .getWithdrawBankList:
			return .get
		}
	}
}
