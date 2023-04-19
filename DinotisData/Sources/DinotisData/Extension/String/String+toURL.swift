//
//  String+toURL.swift
//  
//
//  Created by Gus Adi on 09/12/22.
//

import Foundation

public extension String {
	func toURL() -> URL? {
		return URL(string: self)
	}
}
