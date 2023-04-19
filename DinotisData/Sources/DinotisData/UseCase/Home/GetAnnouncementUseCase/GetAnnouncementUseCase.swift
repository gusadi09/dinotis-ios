//
//  File.swift
//  
//
//  Created by Gus Adi on 30/03/23.
//

import Foundation

public protocol GetAnnouncementUseCase {
    func execute() async -> Result<AnnouncementResponse, Error>
}
