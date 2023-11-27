//
//  File.swift
//  
//
//  Created by Gus Adi on 29/03/23.
//

import Foundation

public struct UploadResponse: Codable {
    public let url: String?
    
    public init(url: String?) {
        self.url = url
    }
}

public struct UploadVideoSignedResponse: Codable {
    public let fullUrl: String?
    public let baseUrl: String?
    public let publicUrl: String?
    public let path: String?
    public let queryParams: QueryParamsData?
    public let headers: HeaderData?
    
    public init(fullUrl: String?, baseUrl: String?, publicUrl: String?, path: String?, queryParams: QueryParamsData?, headers: HeaderData?) {
        self.fullUrl = fullUrl
        self.baseUrl = baseUrl
        self.publicUrl = publicUrl
        self.path = path
        self.queryParams = queryParams
        self.headers = headers
    }
}

public struct DinotisProgressResponse: Codable {
    public let progress: Double
    public let complete: Bool
    
    public init(progress: Double, complete: Bool) {
        self.progress = progress
        self.complete = complete
    }
}

public typealias DinotisProgressBlock = (_ progress: DinotisProgressResponse) -> Void

public struct QueryParamsData: Codable {
    public let XGoogAlgorithm: String?
    public let XGoogCredential: String?
    public let XGoogDate: String?
    public let XGoogExpires: String?
    public let XGoogSignedHeaders: String?
    public let XGoogSignature: String?
    
    public init(XGoogAlgorithm: String? = nil, XGoogCredential: String? = nil, XGoogDate: String? = nil, XGoogExpires: String? = nil, XGoogSignedHeaders: String? = nil, XGoogSignature: String? = nil) {
        self.XGoogAlgorithm = XGoogAlgorithm
        self.XGoogCredential = XGoogCredential
        self.XGoogDate = XGoogDate
        self.XGoogExpires = XGoogExpires
        self.XGoogSignedHeaders = XGoogSignedHeaders
        self.XGoogSignature = XGoogSignature
    }
    
    enum CodingKeys: String, CodingKey {
        case XGoogAlgorithm = "X-Goog-Algorithm"
        case XGoogCredential = "X-Goog-Credential"
        case XGoogDate = "X-Goog-Date"
        case XGoogExpires = "X-Goog-Expires"
        case XGoogSignedHeaders = "X-Goog-SignedHeaders"
        case XGoogSignature = "X-Goog-Signature"
    }
}

public struct HeaderData: Codable {
    public let ContentType: String?
    
    public init(ContentType: String? = nil) {
        self.ContentType = ContentType
    }
    
    enum CodingKeys: String, CodingKey {
        case ContentType = "Content-Type"
    }
}

public struct UploadMultipleResponse: Codable {
    public let urls: [String]?
    
    public init(urls: [String]?) {
        self.urls = urls
    }
}
