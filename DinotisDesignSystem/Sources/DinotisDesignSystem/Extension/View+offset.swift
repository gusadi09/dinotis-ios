//
//  File.swift
//  
//
//  Created by Irham Naufal on 01/09/23.
//

import SwiftUI

public extension View {
    @ViewBuilder
    func offset(_ id: String, offset: @escaping (CGFloat) -> ()) -> some View {
        self
            .overlay {
                GeometryReader { proxy in
                    let minY = proxy.frame(in: .named(id)).minY
                    
                    Color.clear
                        .preference(key: OffsetPreference.self, value: minY)
                        .onPreferenceChange(OffsetPreference.self) { value in
                            offset(value)
                        }
                }
            }
    }
    
    @ViewBuilder
    func offsetH(_ id: String, offset: @escaping (CGFloat) -> ()) -> some View {
        self
            .overlay {
                GeometryReader { proxy in
                    let minX = proxy.frame(in: .named(id)).minX
                    
                    Color.clear
                        .preference(key: OffsetPreference.self, value: minX)
                        .onPreferenceChange(OffsetPreference.self) { value in
                            offset(value)
                        }
                }
            }
    }
}
