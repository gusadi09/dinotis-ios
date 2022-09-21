//
//  ReportDefaultRemoteDataSource.swift
//  DinotisApp
//
//  Created by Gus Adi on 13/03/22.
//

import Foundation
import Moya
import Combine

final class ReportDefaultRemoteDataSource: ReportRemoteDataSource {
	
	private let provider: MoyaProvider<ReportTargetType>
	
	init(provider: MoyaProvider<ReportTargetType> = .defaultProvider()) {
		self.provider = provider
	}
	
	func sendPanicReport(with params: ReportParams) -> AnyPublisher<ReportResponse, UnauthResponse> {
		provider.request(.sendPanicReport(params), model: ReportResponse.self)
	}
	
	func getPanicReportReason() -> AnyPublisher<ReportReasonResponse, UnauthResponse> {
		provider.request(.getPanicReportReason, model: ReportReasonResponse.self)
	}
}
