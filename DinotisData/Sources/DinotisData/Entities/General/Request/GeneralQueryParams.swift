//
//  File.swift
//  
//
//  Created by Gus Adi on 03/02/23.
//

import Foundation

public struct GeneralParameterRequest: Codable {
	public var skip: Int
	public var take: Int

	public init(skip: Int, take: Int) {
		self.skip = skip
		self.take = take
	}
}
