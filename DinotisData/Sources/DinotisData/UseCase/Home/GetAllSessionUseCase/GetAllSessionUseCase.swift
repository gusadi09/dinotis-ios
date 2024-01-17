//
//  File.swift
//  
//
//  Created by Irham Naufal on 08/01/24.
//

import Foundation

public protocol GetAllSessionUseCase {
    func execute(with request: HomeContentRequest) async -> Result<DataResponse<MeetingDetailResponse>, Error>
}
