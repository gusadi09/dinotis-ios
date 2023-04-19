//
//  PaymentInstructionLoader.swift
//  DinotisApp
//
//  Created by Gus Adi on 06/11/22.
//

import Foundation

public final class PaymentInstructionLoader {
    
    public init() {}
    
	private func loadJson(
		fromURL url: URL,
		completion: @escaping (Result<Data, Error>) -> Void
	) {

		URLSession.shared.dataTask(with: url) { (data, _, error) in
			if let error = error {
				completion(.failure(error))
			}

			if let data = data {

				completion(.success(data))
			}
		}.resume()

	}

	public func paymentInstruction(completion: @escaping (([PaymentInstructionData]?, ErrorResponse?) -> Void)) {
		guard let url = URL(string: "\(Configuration.shared.environment.openURL)json/payment-method-how-to.json") else { return }
		loadJson(fromURL: url) { result in
			switch result {
			case .success(let data):
				do {
					let decodedData = try JSONDecoder().decode([PaymentInstructionData].self,
															   from: data)

					completion(decodedData, nil)
				} catch {
                    let data = ErrorResponse(statusCode: 0, message: error.localizedDescription, fields: nil, error: nil, errorCode: nil)
					completion(nil, data)
				}

			case .failure(let error):
                let data = ErrorResponse(statusCode: 0, message: error.localizedDescription, fields: nil, error: nil, errorCode: nil)
				completion(nil, data)
			}
		}
	}
}
