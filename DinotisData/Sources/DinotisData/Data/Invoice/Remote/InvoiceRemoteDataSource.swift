//
//  InvoiceRemoteDataSource.swift
//  DinotisApp
//
//  Created by Gus Adi on 06/11/22.
//

import Foundation
import Moya
import Combine

public protocol InvoiceRemoteDataSource {
	func getInvoice(by bookingID: String) async throws -> InvoiceResponse
}
