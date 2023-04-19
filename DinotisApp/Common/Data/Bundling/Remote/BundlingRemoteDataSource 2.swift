//
//  BundlingRemoteDataSource.swift
//  DinotisApp
//
//  Created by Garry on 02/11/22.
//

import Foundation
import Combine

protocol BundlingRemoteDataSource {
    func createBundling(body: CreateBundling) -> AnyPublisher<CreateBundlingResponse, UnauthResponse>
    func getMeetingList() -> AnyPublisher<MeetingListResponse, UnauthResponse>
}
