//
//  File.swift
//  
//
//  Created by Gus Adi on 29/03/23.
//

import Foundation
import UIKit
import Moya

public protocol UploadPhotoRemoteDataSource {
    func uploadSingleImage(with image: UIImage) async throws -> UploadResponse
    func uploadMultipleImage(with images: [UIImage]) async throws -> UploadMultipleResponse
    func uploadVideoSignedURL(with ext: String) async throws -> UploadVideoSignedResponse
}
