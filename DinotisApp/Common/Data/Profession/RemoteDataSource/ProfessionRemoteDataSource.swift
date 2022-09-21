//
//  ProfessionRemoteDataSource.swift
//  DinotisApp
//
//  Created by Gus Adi on 22/02/22.
//

import Foundation
import Combine

protocol ProfessionRemoteDataSource {
	func getProfession() -> AnyPublisher<ProfessionResponse, UnauthResponse>
	func getCategory() -> AnyPublisher<CategoriesResponse, UnauthResponse>
	func getProfessionByCategory(categoryId: Int) -> AnyPublisher<ProfessionResponse, UnauthResponse>
}
