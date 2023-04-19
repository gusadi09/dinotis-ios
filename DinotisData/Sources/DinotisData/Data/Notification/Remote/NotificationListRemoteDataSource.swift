//
//  NotificationListRemoteDataSource.swift
//  DinotisApp
//
//  Created by Gus Adi on 22/12/22.
//

import Foundation
import Combine

public protocol NotificationListRemoteDataSource {
	func getNotifications(with query: NotificationRequest) async throws -> NotificationResponse
    func readAllNotification() async throws -> SuccessResponse
    func readById(by id: String) async throws -> SuccessResponse
}
