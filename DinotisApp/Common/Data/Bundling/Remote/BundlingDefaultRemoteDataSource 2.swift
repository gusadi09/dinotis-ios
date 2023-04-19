//
//  BundlingDefaultRemoteDataSource.swift
//  DinotisApp
//
//  Created by Garry on 02/11/22.
//

import Foundation
import Moya
import Combine

final class BundlingDefaultRemoteDataSource: BundlingRemoteDataSource {
    
    private let provider: MoyaProvider<BundlingTargetType>
    
    init(provider: MoyaProvider<BundlingTargetType> = .defaultProvider()) {
        self.provider = provider
    }
    
    func createBundling(body: CreateBundling) -> AnyPublisher<CreateBundlingResponse, UnauthResponse> {
        self.provider.request(.createBundling(body), model: CreateBundlingResponse.self)
    }
    
    func getMeetingList() -> AnyPublisher<MeetingListResponse, UnauthResponse> {
        self.provider.request(.getMeetingList, model: MeetingListResponse.self)
    }
}
