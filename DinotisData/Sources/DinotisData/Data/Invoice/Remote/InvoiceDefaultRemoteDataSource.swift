//
//  InvoiceDefaultRemoteDataSource.swift
//  DinotisApp
//
//  Created by Gus Adi on 06/11/22.
//

import Foundation
import Combine
import Moya

public final class InvoiceDefaultRemoteDataSource: InvoiceRemoteDataSource {

	private let provider: MoyaProvider<InvoiceTargetType>

	public init(provider: MoyaProvider<InvoiceTargetType> = .defaultProvider()) {
		self.provider = provider
	}

	public func getInvoice(by bookingID: String) async throws -> InvoiceResponse {
		try await self.provider.request(.getInvoice(bookingID), model: InvoiceResponse.self)
	}
}
