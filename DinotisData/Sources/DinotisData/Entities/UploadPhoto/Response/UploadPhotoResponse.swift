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

public struct UploadMultipleResponse: Codable {
    public let urls: [String]?
    
    public init(urls: [String]?) {
        self.urls = urls
    }
}
