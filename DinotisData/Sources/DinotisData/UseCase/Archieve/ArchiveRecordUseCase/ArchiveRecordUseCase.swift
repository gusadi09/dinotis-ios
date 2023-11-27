//
//  File.swift
//  
//
//  Created by Gus Adi on 25/11/23.
//

import Foundation

public protocol ArchiveRecordUseCase {
    func execute(with meetingId: String) async -> Result<String, Error>
}
