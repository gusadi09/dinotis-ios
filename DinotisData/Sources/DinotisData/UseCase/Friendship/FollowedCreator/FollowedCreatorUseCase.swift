//
//  File.swift
//  
//
//  Created by Gus Adi on 23/02/23.
//

import Foundation

public protocol FollowedCreatorUseCase {
	func execute(with params: GeneralParameterRequest) async -> Result<FriendshipResponse, Error>
}
