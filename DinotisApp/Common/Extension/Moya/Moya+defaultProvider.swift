//
//  Moya+defaultProvider.swift
//  DinotisApp
//
//  Created by Gus Adi on 12/02/22.
//

import Foundation
import Moya

extension MoyaProvider {
	static func defaultProvider() -> MoyaProvider {
		let tokenSource = StateObservable.shared
		
		let accessTokenPlugin = AccessTokenPlugin(tokenClosure: { _ in
			tokenSource.accessToken
		})
		return MoyaProvider(plugins: [NetworkLoggerPlugin(), accessTokenPlugin])
	}
}
