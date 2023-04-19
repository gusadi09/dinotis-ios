//
//  File.swift
//  
//
//  Created by Gus Adi on 08/03/23.
//

import Foundation

public protocol GetInvoiceUseCase {
    func execute(by bookingID: String) async -> Result<InvoiceResponse, Error>
}
