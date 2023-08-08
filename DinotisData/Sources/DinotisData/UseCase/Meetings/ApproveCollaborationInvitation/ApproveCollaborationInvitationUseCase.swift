//
//  File.swift
//  
//
//  Created by Gus Adi on 09/08/23.
//

import Foundation

public protocol ApproveCollaborationInvitationUseCase {
    func execute(_ isApprove: Bool, for meetingId: String) async -> Result<SuccessResponse, Error>
}
