//
//  BundlingRepository.swift
//  DinotisApp
//
//  Created by Garry on 02/11/22.
//

import Foundation
import Combine

protocol BundlingRepository {
    func provideCreateBundling(body: CreateBundling) -> AnyPublisher<CreateBundlingResponse, UnauthResponse>
    func provideGetMeetingList() -> AnyPublisher<MeetingListResponse, UnauthResponse>
}
