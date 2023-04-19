//
//  ProfessionRepository.swift
//  DinotisApp
//
//  Created by Gus Adi on 22/02/22.
//

import Foundation
import Combine

public protocol ProfessionRepository {
	func provideGetProfession() async throws -> ProfessionResponse
	func provideGetCategory() async throws -> CategoriesResponse
	func provideGetProfessionByCategory(with categoryId: Int) async throws -> ProfessionResponse
}
