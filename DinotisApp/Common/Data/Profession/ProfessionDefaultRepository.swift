//
//  ProfessionDefaultRepository.swift
//  DinotisApp
//
//  Created by Gus Adi on 22/02/22.
//

import Foundation
import Combine

final class ProfessionDefaultRepository: ProfessionRepository {
	
	private let remoteDataSource: ProfessionRemoteDataSource
	
	init(remoteDataSource: ProfessionRemoteDataSource = ProfessionDefaultRemoteDataSource()) {
		self.remoteDataSource = remoteDataSource
	}
	
	func provideGetProfession() -> AnyPublisher<ProfessionResponse, UnauthResponse> {
		self.remoteDataSource.getProfession()
	}
	
	func provideGetCategory() -> AnyPublisher<CategoriesResponse, UnauthResponse> {
		self.remoteDataSource.getCategory()
	}
	
	func provideGetProfessionByCategory(with categoryId: Int) -> AnyPublisher<ProfessionResponse, UnauthResponse> {
		self.remoteDataSource.getProfessionByCategory(categoryId: categoryId)
	}
}
