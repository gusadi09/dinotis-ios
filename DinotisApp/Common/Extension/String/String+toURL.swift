//
//  String+toURL.swift
//  DinotisApp
//
//  Created by Gus Adi on 15/12/21.
//

import Foundation

extension String {
	func toURL() -> URL? {
		return URL(string: self)
	}
}
