//
//  File.swift
//  
//
//  Created by Gus Adi on 09/03/23.
//

import Foundation

public struct EditUserRequest: Codable {
    public var name: String?
    public var username: String?
    public var profilePhoto: String?
    public var profileDescription: String?
    public var userHighlights: [String]?
    public var professions: [Int]?
    public var password: String?
    public var confirmPassword: String?
    
    public enum CodingKeys: String, CodingKey {
        case name, username, profilePhoto, profileDescription
        case userHighlights, professions, password, confirmPassword
    }
    
    public init(name: String?, username: String?, profilePhoto: String?, profileDescription: String?, userHighlights: [String]?, professions: [Int]?, password: String?, confirmPassword: String?) {
        self.name = name
        self.username = username
        self.profilePhoto = profilePhoto
        self.profileDescription = profileDescription
        self.userHighlights = userHighlights
        self.professions = professions
        self.password = password
        self.confirmPassword = confirmPassword
    }
}

public struct UsernameSuggestionRequest: Codable {
    public var name: String
    
    public init(name: String) {
        self.name = name
    }
}

public struct UsernameAvailabilityRequest: Codable {
    public var username: String
    
    public init(username: String) {
        self.username = username
    }
}

public struct EditUserPhotoRequest: Codable {
    public var profilePhoto: String
    
    public init(profilePhoto: String) {
        self.profilePhoto = profilePhoto
    }
}

public struct CreatorAvailabilityRequest: Codable {
    public var availability: Bool
    public var price: Int
    public var type: SubscriptionUserType?
    
    public init(availability: Bool, price: Int, type: SubscriptionUserType?) {
        self.availability = availability
        self.price = price
        self.type = type
    }
}
