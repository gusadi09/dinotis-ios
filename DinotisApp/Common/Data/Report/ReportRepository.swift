//
//  ReportRepository.swift
//  DinotisApp
//
//  Created by Gus Adi on 13/03/22.
//

import Foundation
import Combine

protocol ReportRepository {
	func provideSendPanicReport(with params: ReportParams) -> AnyPublisher<ReportResponse, UnauthResponse>
	func provideGetReportReason() -> AnyPublisher<ReportReasonResponse, UnauthResponse>
}
