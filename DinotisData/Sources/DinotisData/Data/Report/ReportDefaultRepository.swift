//
//  ReportDefaultRepository.swift
//  DinotisApp
//
//  Created by Gus Adi on 13/03/22.
//

import Foundation

public final class ReportDefaultRepository: ReportRepository {
	
	private let remote: ReportRemoteDataSource
	
    public init(remote: ReportRemoteDataSource = ReportDefaultRemoteDataSource()) {
		self.remote = remote
	}
	
    public func provideSendPanicReport(with params: ReportRequest) async throws -> ReportResponse {
		try await self.remote.sendPanicReport(with: params)
	}
	
    public func provideGetReportReason() async throws -> ReportReasonResponse {
		try await self.remote.getPanicReportReason()
	}
}
