//
//  TrendingRepo.swift
//  DinotisApp
//
//  Created by Gus Adi on 30/10/21.
//

import Foundation

class TrendingRepo {
	static let shared = TrendingRepo()
	
	let baseUrl  = Configuration.shared.environment.baseURL
	
	var getTrendingTalent: URL {
		return URL(string: baseUrl + "/trending-talent")!
	}
	
	var getRecommendTalent: URL {
		return URL(string: baseUrl + "/recommendation-talent")!
	}
}
