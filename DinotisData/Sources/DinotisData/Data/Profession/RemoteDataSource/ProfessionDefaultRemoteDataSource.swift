//
//  ProfessionDefaultRemoteDataSource.swift
//  DinotisApp
//
//  Created by Gus Adi on 22/02/22.
//

import Foundation
import Moya
import Combine

public final class ProfessionDefaultRemoteDataSource: ProfessionRemoteDataSource {
	
	private let provider: MoyaProvider<ProfessionTargetType>
	
    public init(provider: MoyaProvider<ProfessionTargetType> = .defaultProvider()) {
		self.provider = provider
	}
	
    public func getProfession() async throws -> ProfessionResponse {
        try await provider.request(.getProfession, model: ProfessionResponse.self)
	}
	
    public func getCategory() async throws -> CategoriesResponse {
        try await provider.request(.getCategory, model: CategoriesResponse.self)
	}
	
    public func getProfessionByCategory(categoryId: Int) async throws -> ProfessionResponse {
        try await provider.request(.getProfessionByCategory(categoryId), model: ProfessionResponse.self)
	}
}
