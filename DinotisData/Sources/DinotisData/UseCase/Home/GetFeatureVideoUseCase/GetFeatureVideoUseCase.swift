//
//  GetFeatureVideoUseCase.swift
//  
//
//  Created by Irham Naufal on 09/01/24.
//

import Foundation

public protocol GetFeatureVideoUseCase {
    func execute(with request: FollowingContentRequest) async -> Result<DataResponse<MineVideoData>, Error>
}
