//
//  File.swift
//  
//
//  Created by Gus Adi on 03/03/23.
//

import Foundation

public protocol NotificationListsUseCase {
    func execute(with params: NotificationRequest) async -> Result<NotificationResponse, Error>
}
