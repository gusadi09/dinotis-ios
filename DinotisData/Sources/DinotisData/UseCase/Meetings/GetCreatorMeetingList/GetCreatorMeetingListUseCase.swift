//
//  File.swift
//  
//
//  Created by Gus Adi on 09/08/23.
//

import Foundation

public protocol GetCreatorMeetingListUseCase {
    func execute(with params: MeetingsPageRequest) async -> Result<TalentMeetingResponse, Error>
}
