//
//  File.swift
//  
//
//  Created by Gus Adi on 29/03/23.
//

import Foundation
import Moya
import UIKit

public enum UploadPhotoTargetType {
    case uploadPhoto(UIImage)
    case uploadMultiplePhoto([UIImage])
}

extension UploadPhotoTargetType: DinotisTargetType, AccessTokenAuthorizable {
    var parameters: [String : Any] {
        switch self {
        case .uploadPhoto:
            return [:]
            
        case .uploadMultiplePhoto:
            return[:]
        }
    }
    
    public var headers: [String : String]? {
        return ["Content-type": "multipart/form-data"]
    }
    
    public var authorizationType: AuthorizationType? {
        return .bearer
    }
    
    var parameterEncoding: Moya.ParameterEncoding {
        switch self {
        case .uploadPhoto:
            return URLEncoding.default
            
        case .uploadMultiplePhoto:
            return URLEncoding.default
        }
    }
    
    public var task: Task {
        switch self {
        case .uploadPhoto(let photo):
            let imageData = photo.jpegData(compressionQuality: 0.5) ?? Data()
            let multipartFormData = MultipartFormData(provider: .data(imageData), name: "file", fileName: "photo.png", mimeType: "image/png")
            return .uploadMultipart([multipartFormData])
            
        case .uploadMultiplePhoto(let photos):
            var multipartFormData: [MultipartFormData] = []
            
            for (index, photo) in photos.enumerated() {
                let imageData = photo.jpegData(compressionQuality: 0.5) ?? Data()
                let formData = MultipartFormData(provider: .data(imageData), name: "files", fileName: "photo\(index).png", mimeType: "image/png")
                multipartFormData.append(formData)
            }
            
            return .uploadMultipart(multipartFormData)
        }
    }
    
    public var path: String {
        switch self {
        case .uploadPhoto:
            return "/uploads/single"
            
        case .uploadMultiplePhoto:
            return "/uploads/multiple"
        }
    }
    
    public var method: Moya.Method {
        switch self {
        case .uploadPhoto:
            return .post
            
        case .uploadMultiplePhoto:
            return .post
        }
    }
}
