//
//  File.swift
//  
//
//  Created by Gus Adi on 06/11/23.
//

import Foundation
import Moya

public protocol SignedURLRemoteDataSource {
    func putSignedURL(baseURL: String, path: String, params: QueryParamsData, header: HeaderData, video: Data, ext: String, progress: ProgressBlock?) async throws -> String
    func downloadVideo(url: String, filename: String, isCancel: Bool, progress: ProgressBlock?) async throws -> String
}
