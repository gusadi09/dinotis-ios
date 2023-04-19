//
//  NotificationListRepository.swift
//  DinotisApp
//
//  Created by Gus Adi on 22/12/22.
//

import Foundation
import Combine

public protocol NotificationListRepository {
	func provideGetNotifications(with query: NotificationRequest) async throws -> NotificationResponse
    func provideReadAllNotification() async throws -> SuccessResponse
    func provideReadById(by id: String) async throws -> SuccessResponse
}
