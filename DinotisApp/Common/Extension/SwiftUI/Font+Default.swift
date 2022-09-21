//
//  Font+Default.swift
//  DinotisApp
//
//  Created by Gus Adi on 24/11/21.
//

import Foundation
import SwiftUI

extension Font {
	static func montserratBlack(size: CGFloat) -> Font {
		return .custom("Montserrat-Black", size: size)
	}
	
	static func montserratBlackItalic(size: CGFloat) -> Font {
		return .custom("Montserrat-BlackItalic", size: size)
	}
	
	static func montserratBold(size: CGFloat) -> Font {
		return .custom("Montserrat-Bold", size: size)
	}
	
	static func montserratBoldItalic(size: CGFloat) -> Font {
		return .custom("Montserrat-BoldItalic", size: size)
	}
	
	static func montserratRegular(size: CGFloat) -> Font {
		return .custom("Montserrat-Regular", size: size)
	}
	
	static func montserratSemiBold(size: CGFloat) -> Font {
		return .custom("Montserrat-SemiBold", size: size)
	}
	
	static func montserratMedium(size: CGFloat) -> Font {
		return .custom("Montserrat-Medium", size: size)
	}
}
