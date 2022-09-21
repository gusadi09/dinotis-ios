//
//  ProfessionRepository.swift
//  DinotisApp
//
//  Created by Gus Adi on 22/02/22.
//

import Foundation
import Combine

protocol ProfessionRepository {
	func provideGetProfession() -> AnyPublisher<ProfessionResponse, UnauthResponse>
	func provideGetCategory() -> AnyPublisher<CategoriesResponse, UnauthResponse>
	func provideGetProfessionByCategory(with categoryId: Int) -> AnyPublisher<ProfessionResponse, UnauthResponse>
}
