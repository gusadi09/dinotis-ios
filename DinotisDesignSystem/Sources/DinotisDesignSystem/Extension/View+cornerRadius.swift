//
//  File.swift
//  
//
//  Created by Irham Naufal on 01/09/23.
//

import SwiftUI

public extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedShape(radius: radius, corners: corners))
    }
}
