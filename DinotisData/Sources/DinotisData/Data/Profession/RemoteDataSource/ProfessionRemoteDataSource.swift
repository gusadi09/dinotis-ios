//
//  ProfessionRemoteDataSource.swift
//  DinotisApp
//
//  Created by Gus Adi on 22/02/22.
//

import Foundation
import Combine

public protocol ProfessionRemoteDataSource {
	func getProfession() async throws -> ProfessionResponse
	func getCategory() async throws -> CategoriesResponse
	func getProfessionByCategory(categoryId: Int) async throws -> ProfessionResponse
}
