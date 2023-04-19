//
//  String+load.swift
//  DinotisApp
//
//  Created by Gus Adi on 25/04/22.
//

import Foundation
import UIKit

public extension String {
	func load() -> UIImage {

		if let urlImage = URL(string: "\(Configuration.shared.environment.baseURL)/uploads/" + (self)) {

			if let data = try? Data(contentsOf: urlImage) {
				if let image = UIImage(data: data) {
					return image
				} else {
					return UIImage()
				}
			} else {
				return UIImage()
			}
		} else {
			return UIImage()
		}
	}
}
