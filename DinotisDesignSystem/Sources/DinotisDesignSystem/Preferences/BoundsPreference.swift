//
//  File.swift
//  
//
//  Created by Irham Naufal on 14/08/23.
//

import SwiftUI

public struct BoundsPreference: PreferenceKey {
    public static var defaultValue: [String : Anchor<CGRect>] = [:]
    
    public static func reduce(value: inout [String : Anchor<CGRect>], nextValue: () -> [String : Anchor<CGRect>]) {
        value.merge(nextValue()) { $1 }
    }
}
