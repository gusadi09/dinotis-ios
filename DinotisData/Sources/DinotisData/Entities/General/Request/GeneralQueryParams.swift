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
    public var sort: MineVideoSorting?

    public init(skip: Int, take: Int, sort: MineVideoSorting? = nil) {
		self.skip = skip
		self.take = take
        self.sort = sort
	}
}
