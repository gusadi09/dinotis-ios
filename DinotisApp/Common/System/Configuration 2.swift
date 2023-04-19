//
//  Configuration.swift
//  DinotisApp
//
//  Created by Gus Adi on 30/10/21.
//

import SwiftUI

class Configuration {
	
	static let shared = Configuration()
	
	lazy var environment: EnvironmentApi = {
		if let configuration = Bundle.main.object(forInfoDictionaryKey: "Configuration") as? String {
			if configuration.range(of: "Development") != nil {
				return EnvironmentApi.development
			}
		}
		
		return EnvironmentApi.production
	}()
}
