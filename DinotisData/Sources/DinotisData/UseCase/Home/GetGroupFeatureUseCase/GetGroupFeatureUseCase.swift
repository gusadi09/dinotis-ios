//
//  File.swift
//  
//
//  Created by Gus Adi on 30/03/23.
//

import Foundation

public protocol GetGroupFeatureUseCase {
    func execute() async -> Result<FeatureMeetingResponse, Error>
}
