//
//  File.swift
//  
//
//  Created by Gus Adi on 09/08/23.
//

import Foundation

public protocol EndCreatorMeetingUseCase {
    func execute(for meetingId: String) async -> Result<MeetingDetailResponse, Error>
}
