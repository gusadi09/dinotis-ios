//
//  String+Digits.swift
//  DinotisApp
//
//  Created by Gus Adi on 22/02/22.
//

import Foundation

extension String {
	var digits: [Int] {
		var result = [Int]()
		
		for char in self {
			if let number = Int(String(char)) {
				result.append(number)
			}
		}
		
		return result
	}
	
}
