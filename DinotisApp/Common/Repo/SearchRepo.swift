//
//  SearchRepo.swift
//  DinotisApp
//
//  Created by Gus Adi on 30/09/21.
//

import Foundation

class SearchRepo {
	static let shared = SearchRepo()
	
	let baseUrl  = Configuration.shared.environment.baseURL
	
	var searchQuery = QuerySearch(query: "", skip: 0, take: 0, profession: 0)
	
	var username = ""
	
	var search: URL {
		if searchQuery.profession != nil {
			return URL(
				string: baseUrl +
				"/talents?query=\(searchQuery.query ?? "")" +
				"&skip=\(searchQuery.skip ?? 0)" +
				"&take=\(searchQuery.take ?? 10)" +
				"&profession=\(searchQuery.profession ?? 0)"
			)!
		} else {
			return URL(string: baseUrl + "/talents?query=\(searchQuery.query ?? "")&skip=\(searchQuery.skip ?? 0)&take=\(searchQuery.take ?? 10)")!
		}
	}
	
	var getTalent: URL {
		return URL(string: baseUrl + "/talents/\(username)")!
	}
}
