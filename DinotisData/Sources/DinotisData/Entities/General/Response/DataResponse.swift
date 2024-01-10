//
//  File.swift
//  
//
//  Created by Irham Naufal on 08/01/24.
//

import Foundation

public struct DataResponse<T: Codable>: Codable {
    public let data: [T]?
    public let nextCursor: Int?
    
    public init(data: [T]?, nextCursor: Int?) {
        self.data = data
        self.nextCursor = nextCursor
    }
}
