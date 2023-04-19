//
//  File.swift
//  
//
//  Created by Gus Adi on 16/01/23.
//

import Foundation
import Moya

public extension MoyaProvider {
	static func defaultProvider() -> MoyaProvider {
		let tokenSource = StateObservable.shared

		let accessTokenPlugin = AccessTokenPlugin(tokenClosure: { _ in
			tokenSource.accessToken
		})
		return MoyaProvider(plugins: [NetworkLoggerPlugin(), accessTokenPlugin])
	}
}
