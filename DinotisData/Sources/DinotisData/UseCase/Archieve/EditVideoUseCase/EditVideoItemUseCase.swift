//
//  File.swift
//  
//
//  Created by Gus Adi on 15/11/23.
//

import Foundation

public protocol EditVideoItemUseCase {
    func execute(for id: String, with body: VideosRequest) async -> Result<SuccessResponse, Error>
}
