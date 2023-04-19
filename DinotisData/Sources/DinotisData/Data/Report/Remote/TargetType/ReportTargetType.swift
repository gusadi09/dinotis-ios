//
//  ReportTargetType.swift
//  DinotisApp
//
//  Created by Gus Adi on 13/03/22.
//

import Foundation
import Moya

public enum ReportTargetType {
	case sendPanicReport(ReportRequest)
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
	
    public var authorizationType: AuthorizationType? {
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
	
    public var task: Task {
		return .requestParameters(parameters: parameters, encoding: parameterEncoding)
	}
	
    public var path: String {
		switch self {
		case .sendPanicReport:
			return "/meetings/report/create"
			
		case .getPanicReportReason:
			return "/meetings/report/reasons"
		}
	}
	
    public var method: Moya.Method {
		switch self {
		case .sendPanicReport:
			return .post
			
		case .getPanicReportReason:
			return .get
		}
	}
}
