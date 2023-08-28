//
//  File.swift
//  
//
//  Created by Irham Naufal on 28/08/23.
//

import SwiftUI

public extension String {
    func containURL(whiteText: Bool = false, size: CGFloat) -> AttributedString {
        
        var attributedString = AttributedString(self)
        
        let types = NSTextCheckingResult.CheckingType.link.rawValue | NSTextCheckingResult.CheckingType.phoneNumber.rawValue
        
        guard let detector = try? NSDataDetector(types: types) else {
            return attributedString
        }
        
        let matches = detector.matches(in: self, options: [], range: NSRange(location: 0, length: count))
        
        for match in matches {
            let range = match.range
            let startIndex = attributedString.index(attributedString.startIndex, offsetByCharacters: range.lowerBound)
            let endIndex = attributedString.index(startIndex, offsetByCharacters: range.length)
            if match.resultType == .link, let url = match.url {
                attributedString[startIndex..<endIndex].link = url
                attributedString[startIndex..<endIndex].underlineStyle = .single
                attributedString[startIndex..<endIndex].font = .robotoMedium(size: size)
                attributedString[startIndex..<endIndex].underlineColor = whiteText ? .white : .blue
                attributedString[startIndex..<endIndex].foregroundColor = whiteText ? .white : .blue
            }
        }
        return attributedString
    }
}
