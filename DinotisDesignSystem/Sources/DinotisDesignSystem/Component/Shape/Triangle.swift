//
//  File.swift
//  
//
//  Created by Irham Naufal on 14/08/23.
//

import SwiftUI

public struct Triangle: Shape {
    public func path(in rect: CGRect) -> Path {
        return Path { path in
            let center = rect.width/2
            
            path.move(to: CGPoint(x: rect.midX, y: rect.maxY))
            
            path.addLine(to: CGPoint(x: center - 26, y: rect.maxY - 16))
            path.addLine(to: CGPoint(x: center + 26, y: rect.maxY - 16))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        }
    }
}
