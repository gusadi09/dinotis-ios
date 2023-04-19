//
//  File.swift
//  
//
//  Created by Gus Adi on 14/03/23.
//

import Foundation

public protocol SendPanicReportUseCase {
    func execute(with params: ReportRequest) async -> Result<ReportResponse, Error>
}
