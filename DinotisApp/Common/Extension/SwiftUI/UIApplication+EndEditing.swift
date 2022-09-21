//
//  UIApplication+EndEditing.swift
//  DinotisApp
//
//  Created by Gus Adi on 01/12/21.
//

import SwiftUI

extension UIApplication {
	func endEditing() {
		sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
	}
}
