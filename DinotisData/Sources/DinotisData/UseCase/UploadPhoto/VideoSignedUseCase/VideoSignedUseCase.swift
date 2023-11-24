//
//  File.swift
//  
//
//  Created by Gus Adi on 03/11/23.
//

import Foundation

public protocol VideoSignedUseCase {
    func execute(with ext: String) async -> Result<UploadVideoSignedResponse, Error>
}
