//
//  File.swift
//  
//
//  Created by Gus Adi on 02/02/23.
//

import Foundation

public extension Int {
    func kmbFormatter() -> String {
		let formatter = KMBFormatter()

		return formatter.string(fromNumber: Int64(self))
	}
}
