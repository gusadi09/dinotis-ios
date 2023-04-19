//
//  ReportDefaultRemoteDataSource.swift
//  DinotisApp
//
//  Created by Gus Adi on 13/03/22.
//

import Foundation
import Moya

public final class ReportDefaultRemoteDataSource: ReportRemoteDataSource {
	
	private let provider: MoyaProvider<ReportTargetType>
	
    public init(provider: MoyaProvider<ReportTargetType> = .defaultProvider()) {
		self.provider = provider
	}
	
    public func sendPanicReport(with params: ReportRequest) async throws -> ReportResponse {
		try await provider.request(.sendPanicReport(params), model: ReportResponse.self)
	}
	
    public func getPanicReportReason() async throws -> ReportReasonResponse {
		try await provider.request(.getPanicReportReason, model: ReportReasonResponse.self)
	}
}
