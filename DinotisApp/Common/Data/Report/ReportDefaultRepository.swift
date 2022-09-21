//
//  ReportDefaultRepository.swift
//  DinotisApp
//
//  Created by Gus Adi on 13/03/22.
//

import Foundation
import Combine

final class ReportDefaultRepository: ReportRepository {
	
	private let remote: ReportRemoteDataSource
	
	init(remote: ReportRemoteDataSource = ReportDefaultRemoteDataSource()) {
		self.remote = remote
	}
	
	func provideSendPanicReport(with params: ReportParams) -> AnyPublisher<ReportResponse, UnauthResponse> {
		self.remote.sendPanicReport(with: params)
	}
	
	func provideGetReportReason() -> AnyPublisher<ReportReasonResponse, UnauthResponse> {
		self.remote.getPanicReportReason()
	}
}
