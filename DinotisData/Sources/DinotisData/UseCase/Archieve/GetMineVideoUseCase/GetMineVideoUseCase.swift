//
//  File.swift
//  
//
//  Created by Gus Adi on 14/11/23.
//

import Foundation

public protocol GetMineVideoUseCase {
    func execute(with query: MineVideoRequest) async -> Result<MineVideoResponse, Error>
}
