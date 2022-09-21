//
//  ProfessionDefaultRemoteDataSource.swift
//  DinotisApp
//
//  Created by Gus Adi on 22/02/22.
//

import Foundation
import Moya
import Combine

final class ProfessionDefaultRemoteDataSource: ProfessionRemoteDataSource {
	
	private let provider: MoyaProvider<ProfessionTargetType>
	
	init(provider: MoyaProvider<ProfessionTargetType> = .defaultProvider()) {
		self.provider = provider
	}
	
	func getProfession() -> AnyPublisher<ProfessionResponse, UnauthResponse> {
		provider.request(.getProfession, model: ProfessionResponse.self)
	}
	
	func getCategory() -> AnyPublisher<CategoriesResponse, UnauthResponse> {
		provider.request(.getCategory, model: CategoriesResponse.self)
	}
	
	func getProfessionByCategory(categoryId: Int) -> AnyPublisher<ProfessionResponse, UnauthResponse> {
		provider.request(.getProfessionByCategory(categoryId), model: ProfessionResponse.self)
	}
}
