//
//  File.swift
//  
//
//  Created by Gus Adi on 24/02/23.
//

import Foundation

public protocol UnfollowCreatorUseCase {
	func execute(for creatorId: String) async -> Result<SuccessResponse, Error>
}
