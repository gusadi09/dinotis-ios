//
//  File.swift
//  
//
//  Created by Gus Adi on 29/03/23.
//

import Foundation
import UIKit
import Moya

public protocol UploadPhotoRepository {
    func provideUploadSingleImage(with image: UIImage) async throws -> UploadResponse
    func provideUploadMultipleImage(with images: [UIImage]) async throws -> UploadMultipleResponse
    func provideUploadVideoSignedURL(with ext: String) async throws -> UploadVideoSignedResponse
}
