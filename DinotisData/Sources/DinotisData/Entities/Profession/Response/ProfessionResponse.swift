//
//  File.swift
//  
//
//  Created by Gus Adi on 13/03/23.
//

import Foundation

public struct ProfessionResponse: Codable {
    public let data: [ProfessionElement]?
    public let nextCursor: Int?
    
    public init(data: [ProfessionElement]?, nextCursor: Int?) {
        self.data = data
        self.nextCursor = nextCursor
    }
}

public struct CategoriesResponse: Codable {
    public let data: [CategoriesData]?
    public let nextCursor: Int?
    
    public init(data: [CategoriesData]?, nextCursor: Int?) {
        self.data = data
        self.nextCursor = nextCursor
    }
}

public struct CategoriesData: Codable, Identifiable {
    public let id: Int?
    public let name: String?
    public let icon: String?
    public let professions: [CategoriesProfessionData]?
    public let createdAt: Date?
    public let updatedAt: Date?
    
    public init(id: Int?, name: String?, icon: String?, professions: [CategoriesProfessionData]?, createdAt: Date?, updatedAt: Date?) {
        self.id = id
        self.name = name
        self.icon = icon
        self.professions = professions
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

public struct CategoriesProfessionData: Codable {
    public let id: Int?
    public let name: String?
    public let professionCategoryId: Int?
    public let professionCategory: String?
    public let createdAt: Date?
    public let updatedAt: Date?
    
    public init(id: Int?, name: String?, professionCategoryId: Int?, professionCategory: String?, createdAt: Date?, updatedAt: Date?) {
        self.id = id
        self.name = name
        self.professionCategoryId = professionCategoryId
        self.professionCategory = professionCategory
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}
