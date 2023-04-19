//
//  FontInjector.swift
//  
//
//  Created by Gus Adi on 30/11/22.
//

import SwiftUI

public struct FontInjector {
	public static func registerFonts() {
		Roboto.allCases.forEach {
			registerFont(bundle: .module, fontName: $0.rawValue, fontExtension: "ttf")
		}
	}

	fileprivate static func registerFont(bundle: Bundle, fontName: String, fontExtension: String) {

		guard let fontURL = bundle.url(forResource: fontName, withExtension: fontExtension),
			  let fontDataProvider = CGDataProvider(url: fontURL as CFURL),
			  let font = CGFont(fontDataProvider) else {
			fatalError("Couldn't create font from data")
		}

		var error: Unmanaged<CFError>?

		CTFontManagerRegisterGraphicsFont(font, &error)
	}
}

public enum Roboto: String, CaseIterable {
	case regular = "Roboto-Regular"
	case italic = "Roboto-Italic"
	case medium = "Roboto-Medium"
	case mediumItalic = "Roboto-MediumItalic"
	case bold = "Roboto-Bold"
	case boldItalic = "Roboto-BoldItalic"
	case light = "Roboto-Light"
	case lightItalic = "Roboto-LightItalic"
	case thin = "Roboto-Thin"
	case thinItalic = "Roboto-ThinItalic"
}
