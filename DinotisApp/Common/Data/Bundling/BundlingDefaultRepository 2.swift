//
//  BundlingDefaultRepository.swift
//  DinotisApp
//
//  Created by Garry on 02/11/22.
//

import Foundation
import Combine
import Moya

final class BundlingDefaultRepository: BundlingRepository {
    
    private let remote: BundlingRemoteDataSource

    init(remote: BundlingRemoteDataSource = BundlingDefaultRemoteDataSource()) {
        self.remote = remote
    }
    
    func provideCreateBundling(body: CreateBundling) -> AnyPublisher<CreateBundlingResponse, UnauthResponse> {
        self.remote.createBundling(body: body)
    }
    
    func provideGetMeetingList() -> AnyPublisher<MeetingListResponse, UnauthResponse> {
        self.remote.getMeetingList()
    }
}
