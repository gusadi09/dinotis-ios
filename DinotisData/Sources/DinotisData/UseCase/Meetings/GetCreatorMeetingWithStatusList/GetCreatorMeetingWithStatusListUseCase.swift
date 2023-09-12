//
//  File.swift
//  
//
//  Created by Gus Adi on 12/09/23.
//

import Foundation

public protocol GetCreatorMeetingWithStatusListUseCase {
    func execute(with params: MeetingsStatusPageRequest) async -> Result<CreatorMeetingWithStatusResponse, Error>
}
