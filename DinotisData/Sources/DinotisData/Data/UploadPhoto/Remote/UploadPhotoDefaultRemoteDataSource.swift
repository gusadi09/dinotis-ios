//
//  File.swift
//  
//
//  Created by Gus Adi on 29/03/23.
//

import Foundation
import Moya
import UIKit

public final class UploadPhotoDefaultRemoteDataSource: UploadPhotoRemoteDataSource {
    
    private let provider: MoyaProvider<UploadPhotoTargetType>
    
    public init(provider: MoyaProvider<UploadPhotoTargetType> = .defaultProvider()) {
        self.provider = provider
    }
    
    public func uploadSingleImage(with image: UIImage) async throws -> UploadResponse {
        try await self.provider.request(.uploadPhoto(image), model: UploadResponse.self)
    }
    
    public func uploadMultipleImage(with images: [UIImage]) async throws -> UploadMultipleResponse {
        try await self.provider.request(.uploadMultiplePhoto(images), model: UploadMultipleResponse.self)
    }
}
