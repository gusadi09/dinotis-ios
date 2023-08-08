//
//  File.swift
//  
//
//  Created by Gus Adi on 09/08/23.
//

import Foundation

public protocol GetCreatorDetailMeetingListUseCase {
    func execute(for userId: String, with params: MeetingsPageRequest) async -> Result<TalentMeetingResponse, Error>
}
