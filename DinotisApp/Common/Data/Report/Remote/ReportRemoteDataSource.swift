//
//  ReportRemoteDataSource.swift
//  DinotisApp
//
//  Created by Gus Adi on 13/03/22.
//

import Foundation
import Combine

protocol ReportRemoteDataSource {
	func sendPanicReport(with params: ReportParams) -> AnyPublisher<ReportResponse, UnauthResponse>
	func getPanicReportReason() -> AnyPublisher<ReportReasonResponse, UnauthResponse>
}
