//
//  UIImage+Ext.swift
//  DinotisApp
//
//  Created by Gus Adi on 13/03/22.
//

import UIKit

extension UIImage {
	func saveToFile(atURL url: URL) {
		guard let data = self.pngData() else { return }
		do {
			try data.write(to: url)
		} catch {

		}
	}
	
	func saveToDocuments() {
		let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
		let name = "\(Date().timeIntervalSince1970).png"
		let fileURL = paths[0].appendingPathComponent(name)
		saveToFile(atURL: fileURL)
	}
}
