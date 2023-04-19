//
//  File.swift
//  
//
//  Created by Gus Adi on 30/03/23.
//

import Foundation

public protocol GetLatestNoticeUseCase {
    func execute() async -> Result<LatestNoticesResponse, Error>
}
