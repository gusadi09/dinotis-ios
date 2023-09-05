//
//  File.swift
//  
//
//  Created by Irham Naufal on 01/09/23.
//

import SwiftUI

public struct OffsetPreference: PreferenceKey {
    public static var defaultValue: CGFloat = 0
    
    public static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}
