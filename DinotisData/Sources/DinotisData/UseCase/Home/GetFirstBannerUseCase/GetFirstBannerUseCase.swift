//
//  File.swift
//  
//
//  Created by Gus Adi on 30/03/23.
//

import Foundation

public protocol GetFirstBannerUseCase {
    func execute() async -> Result<BannerResponse, Error>
}
