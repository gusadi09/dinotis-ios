//
//  File.swift
//  
//
//  Created by Gus Adi on 06/11/23.
//

import Foundation
import Moya

public final class SignedURLDefaultRemoteDataSource: SignedURLRemoteDataSource {
    
    private var provider: MoyaProvider<SignedURLTargertType>
    
    public init(provider: MoyaProvider<SignedURLTargertType> = .defaultProvider()) {
        self.provider = provider
    }
    
    public func putSignedURL(baseURL: String, path: String, params: QueryParamsData, header: HeaderData, video: Data, ext: String, progress: ProgressBlock?) async throws -> String {
        try await self.provider.request(.uploadSigned(baseURL, path, params, header, video, ext), progress: progress, model: String.self, isSigned: true)
    }
    
    public func downloadVideo(url: String, filename: String, isCancel: Bool, progress: ProgressBlock?) async throws -> String {
        if !isCancel {
            self.provider = .defaultProvider()
        }
        
        return try await self.provider.request(.downloadVideo(url, filename), progress: progress, model: String.self, isSigned: true, isCancel: isCancel)
    }
}
