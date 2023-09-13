//
//  String+load.swift
//  DinotisApp
//
//  Created by Gus Adi on 25/04/22.
//

import Foundation
import UIKit

public extension String {
    func load() async -> UIImage {

		if let urlImage = URL(string: self) {
            
            do {
                let (data, _) = try await URLSession.shared.data(from: urlImage)
                if let image = UIImage(data: data) {
                    return image
                } else {
                    return UIImage()
                }
            } catch {
                return UIImage()
            }
		} else {
			return UIImage()
		}
	}
}
