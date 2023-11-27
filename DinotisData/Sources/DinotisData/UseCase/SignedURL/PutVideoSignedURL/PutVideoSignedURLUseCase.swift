//
//  File.swift
//  
//
//  Created by Gus Adi on 06/11/23.
//

import Foundation
import Moya

public protocol PutVideoSignedURLUseCase {
    func execute(baseURL: String, path: String, params: QueryParamsData, header: HeaderData, video: Data, ext: String, progress: ProgressBlock?) async -> Result<String, Error>
}
