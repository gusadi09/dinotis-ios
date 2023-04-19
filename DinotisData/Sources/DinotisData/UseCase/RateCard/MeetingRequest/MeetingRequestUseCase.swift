//
//  File.swift
//  
//
//  Created by Gus Adi on 26/02/23.
//

import Foundation

public protocol MeetingRequestUseCase {
	func execute(with params: RateCardFilterRequest) async -> Result<MeetingRequestsResponse, Error>
}
