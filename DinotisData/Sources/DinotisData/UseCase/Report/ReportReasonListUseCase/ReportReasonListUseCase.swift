//
//  File.swift
//  
//
//  Created by Gus Adi on 14/03/23.
//

import Foundation

public protocol ReportReasonListUseCase {
    func execute() async -> Result<ReportReasonResponse, Error>
}
