//
//  File.swift
//  
//
//  Created by Gus Adi on 14/11/23.
//

import Foundation

public protocol PostVideoUseCase {
    func execute(with body: VideosRequest) async -> Result<String, Error>
}
