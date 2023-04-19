//
//  InvoiceDefaultRepository.swift
//  DinotisApp
//
//  Created by Gus Adi on 06/11/22.
//

import Foundation
import Combine

public final class InvoiceDefaultRepository: InvoiceRepository {

	private let remote: InvoiceRemoteDataSource

	public init(remote: InvoiceRemoteDataSource = InvoiceDefaultRemoteDataSource()) {
		self.remote = remote
	}

	public func provideGetInvoice(by bookingId: String) async throws -> InvoiceResponse {
		try await self.remote.getInvoice(by: bookingId)
	}
}
