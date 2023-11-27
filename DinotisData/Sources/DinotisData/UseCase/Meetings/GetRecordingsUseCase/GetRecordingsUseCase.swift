//
//  File.swift
//  
//
//  Created by Gus Adi on 23/11/23.
//

import Foundation

public protocol GetRecordingsUseCase {
    func execute(for meetingId: String) async -> Result<RecordingResponse, Error>
}
