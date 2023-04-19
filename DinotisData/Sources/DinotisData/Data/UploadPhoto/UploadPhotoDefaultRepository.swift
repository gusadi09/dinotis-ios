//
//  File.swift
//  
//
//  Created by Gus Adi on 29/03/23.
//

import Foundation
import UIKit

public final class UploadPhotoDefaultRepository: UploadPhotoRepository {
    
    private let remote: UploadPhotoRemoteDataSource
    
    public init(remote: UploadPhotoRemoteDataSource = UploadPhotoDefaultRemoteDataSource()) {
        self.remote = remote
    }
    
    public func provideUploadSingleImage(with image: UIImage) async throws -> UploadResponse {
        try await self.remote.uploadSingleImage(with: image)
    }
    
    public func provideUploadMultipleImage(with images: [UIImage]) async throws -> UploadMultipleResponse {
        try await self.remote.uploadMultipleImage(with: images)
    }
}
