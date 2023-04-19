//
//  ProfessionDefaultRepository.swift
//  DinotisApp
//
//  Created by Gus Adi on 22/02/22.
//

import Foundation
import Combine

public final class ProfessionDefaultRepository: ProfessionRepository {
	
	private let remoteDataSource: ProfessionRemoteDataSource
	
    public init(remoteDataSource: ProfessionRemoteDataSource = ProfessionDefaultRemoteDataSource()) {
		self.remoteDataSource = remoteDataSource
	}
	
    public func provideGetProfession() async throws -> ProfessionResponse {
		try await self.remoteDataSource.getProfession()
	}
	
    public func provideGetCategory() async throws -> CategoriesResponse {
        try await self.remoteDataSource.getCategory()
	}
	
    public func provideGetProfessionByCategory(with categoryId: Int) async throws -> ProfessionResponse {
        try await self.remoteDataSource.getProfessionByCategory(categoryId: categoryId)
	}
}
