//
//  ReportTargetType.swift
//  DinotisApp
//
//  Created by Gus Adi on 13/03/22.
//

import Foundation
import Moya

enum ReportTargetType {
	case sendPanicReport(ReportParams)
	case getPanicReportReason
}

extension ReportTargetType: DinotisTargetType, AccessTokenAuthorizable {
	var parameters: [String : Any] {
		switch self {
		case .sendPanicReport(let params):
			return params.toJSON()
			
		case .getPanicReportReason:
			return[:]
		}
	}
	
	var authorizationType: AuthorizationType? {
		return .bearer
	}
	
	var parameterEncoding: Moya.ParameterEncoding {
		switch self {
		case .sendPanicReport:
			return JSONEncoding.default
			
		case .getPanicReportReason:
			return URLEncoding.default
		}
	}
	
	var task: Task {
		return .requestParameters(parameters: parameters, encoding: parameterEncoding)
	}
	
	var path: String {
		switch self {
		case .sendPanicReport:
			return "/meetings/report/create"
			
		case .getPanicReportReason:
			return "/meetings/report/reasons"
		}
	}
	
	var method: Moya.Method {
		switch self {
		case .sendPanicReport:
			return .post
			
		case .getPanicReportReason:
			return .get
		}
	}
}
