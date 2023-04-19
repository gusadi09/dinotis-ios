//
//  File.swift
//  
//
//  Created by Gus Adi on 30/03/23.
//

import Foundation

public protocol GetPrivateFeatureUseCase {
    func execute() async -> Result<FeatureMeetingResponse, Error>
}
