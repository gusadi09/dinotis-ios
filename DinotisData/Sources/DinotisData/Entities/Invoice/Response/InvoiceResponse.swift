//
//  File.swift
//  
//
//  Created by Gus Adi on 08/03/23.
//

import Foundation

public struct InvoiceResponse: Codable {
    public let id, number, status, userID, externalId: String?
    public let bankID: Int?
    public let expiredAt, createdAt, updatedAt: Date?
    
    public enum CodingKeys: String, CodingKey {
        case id, number, status, externalId
        case userID = "userId"
        case bankID = "bankId"
        case expiredAt, createdAt, updatedAt
    }
    
    public init(id: String?, number: String?, status: String?, userID: String?, externalId: String?, bankID: Int?, expiredAt: Date?, createdAt: Date?, updatedAt: Date?) {
        self.id = id
        self.number = number
        self.status = status
        self.userID = userID
        self.externalId = externalId
        self.bankID = bankID
        self.expiredAt = expiredAt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

public struct PaymentInstructionData: Codable {
    public let id: Int?
    public let paymentMethod:  PaymentMethodInstructionData?
    public let instructions: [InstructionData]?
    
    public init(id: Int?, paymentMethod: PaymentMethodInstructionData?, instructions: [InstructionData]?) {
        self.id = id
        self.paymentMethod = paymentMethod
        self.instructions = instructions
    }
}

public typealias InstructionResponse = [PaymentInstructionData]

public struct PaymentMethodInstructionData: Codable {
    public let id: Int?
    public let name: String?
    public let iconUrl: String?
    public let bankId: Int?
    
    public init(id: Int?, name: String?, iconUrl: String?, bankId: Int?) {
        self.id = id
        self.name = name
        self.iconUrl = iconUrl
        self.bankId = bankId
    }
}

public struct InstructionData: Codable {
    public let name: String?
    public let instruction: [String]?
    
    public init(name: String?, instruction: [String]?) {
        self.name = name
        self.instruction = instruction
    }
}
