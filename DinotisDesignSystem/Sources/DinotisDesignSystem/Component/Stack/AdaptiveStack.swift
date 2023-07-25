//
//  AdaptiveStack.swift
//  
//
//  Created by Irham Naufal on 20/07/23.
//

import SwiftUI

public struct AdaptiveStack<Content: View>: View {
    private let horizontalAlignment: HorizontalAlignment
    private let verticalAlignment: VerticalAlignment
    private let isHorizontalStack: Bool
    private let spacing: CGFloat
    private let content: () -> Content
    
    public init(horizontalAlignment: HorizontalAlignment = .center, verticalAlignment: VerticalAlignment = .center, isHorizontalStack: Bool, spacing: CGFloat, @ViewBuilder content: @escaping () -> Content) {
        self.horizontalAlignment = horizontalAlignment
        self.verticalAlignment = verticalAlignment
        self.isHorizontalStack = isHorizontalStack
        self.spacing = spacing
        self.content = content
    }
    
    public var body: some View {
        Group {
            if isHorizontalStack {
                HStack(alignment: verticalAlignment, spacing: spacing, content: content)
            } else {
                VStack(alignment: horizontalAlignment, spacing: spacing, content: content)
            }
        }
    }
}

struct AdaptiveStack_Previews: PreviewProvider {
    static var previews: some View {
        AdaptiveStack(
            isHorizontalStack: true,
            spacing: 10) {
                Text("Test 1")
                Text("Test 2")
            }
    }
}
