//
//  InvoiceTargetType.swift
//  DinotisApp
//
//  Created by Gus Adi on 06/11/22.
//

import Foundation
import Moya

public enum InvoiceTargetType {
	case getInvoice(String)
}

extension InvoiceTargetType: DinotisTargetType, AccessTokenAuthorizable {
	var parameters: [String : Any] {
		switch self {
		case .getInvoice(_):
			return [:]
		}
	}

    public var authorizationType: AuthorizationType? {
		return .bearer
	}

	var parameterEncoding: Moya.ParameterEncoding {
		switch self {
		case .getInvoice(_):
			return URLEncoding.default
		}
	}

    public var task: Task {
		return .requestParameters(parameters: parameters, encoding: parameterEncoding)
	}

    public var path: String {
		switch self {
		case .getInvoice(let id):
			return "/virtual-accounts/booking/\(id)"
		}
	}

    public var method: Moya.Method {
		switch self {
		case .getInvoice(_):
			return .get
		}
	}
}
