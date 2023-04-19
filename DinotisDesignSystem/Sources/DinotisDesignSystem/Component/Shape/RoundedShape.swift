//
//  SwiftUIView.swift
//  
//
//  Created by Gus Adi on 04/02/23.
//

import SwiftUI

public struct RoundedShape: Shape {
	public var radius: CGFloat = .infinity
	public var corners: UIRectCorner = .allCorners

	public func path(in rect: CGRect) -> Path {
		let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
		return Path(path.cgPath)
	}
}
