//
//  ReportRepository.swift
//  DinotisApp
//
//  Created by Gus Adi on 13/03/22.
//

import Foundation

public protocol ReportRepository {
	func provideSendPanicReport(with params: ReportRequest) async throws -> ReportResponse
	func provideGetReportReason() async throws -> ReportReasonResponse
}
