//
//  ReportRemoteDataSource.swift
//  DinotisApp
//
//  Created by Gus Adi on 13/03/22.
//

import Foundation

public protocol ReportRemoteDataSource {
	func sendPanicReport(with params: ReportRequest) async throws -> ReportResponse
	func getPanicReportReason() async throws -> ReportReasonResponse
}
