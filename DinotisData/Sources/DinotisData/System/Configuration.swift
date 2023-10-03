//
//  Configuration.swift
//  DinotisApp
//
//  Created by Gus Adi on 30/10/21.
//

import SwiftUI

public class Configuration {
	
	public static let shared = Configuration()
	
	public lazy var environment: EnvironmentApi = {
		if let configuration = Bundle.main.object(forInfoDictionaryKey: "Configuration") as? String {
			if configuration.range(of: "Development") != nil {
				return EnvironmentApi.development
            } else if configuration.range(of: "Staging") != nil {
                return EnvironmentApi.staging
            }
		}
		
		return EnvironmentApi.production
	}()
}
