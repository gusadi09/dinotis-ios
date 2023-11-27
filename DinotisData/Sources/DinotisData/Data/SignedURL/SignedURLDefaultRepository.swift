//
//  File.swift
//  
//
//  Created by Gus Adi on 06/11/23.
//

import Foundation
import Moya

public final class SignedURLDefaultRepository: SignedURLRepository {
    
    private let remote: SignedURLRemoteDataSource
    
    public init(remote: SignedURLRemoteDataSource = SignedURLDefaultRemoteDataSource()) {
        self.remote = remote
    }
    
    public func providePutSignedURL(baseURL: String, path: String, params: QueryParamsData, header: HeaderData, video: Data, ext: String, progress: ProgressBlock?) async throws -> String {
        try await self.remote.putSignedURL(baseURL: baseURL, path: path, params: params, header: header, video: video, ext: ext, progress: progress)
    }
    
    public func provideDownloadVideo(url: String, filename: String, isCancel: Bool, progress: Moya.ProgressBlock?) async throws -> String {
        try await self.remote.downloadVideo(url: url, filename: filename, isCancel: isCancel, progress: progress)
    }
}
