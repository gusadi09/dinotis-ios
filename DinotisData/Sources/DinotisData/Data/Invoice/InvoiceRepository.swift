//
//  InvoiceRepository.swift
//  DinotisApp
//
//  Created by Gus Adi on 06/11/22.
//

import Foundation
import Combine

public protocol InvoiceRepository {
	func provideGetInvoice(by bookingId: String) async throws -> InvoiceResponse
}
