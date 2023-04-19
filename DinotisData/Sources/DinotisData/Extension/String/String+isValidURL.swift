//
//  File.swift
//  
//
//  Created by Gus Adi on 18/04/23.
//

import Foundation

public extension String {
    func validateURL() -> Bool {
        // Define the URL regex pattern
        let urlPattern = "^(https?://)?([\\da-z.-]+)\\.([a-z.]{2,6})([/\\w .-]*)*/?$"
        
        // Create a regex object
        let regex = try! NSRegularExpression(pattern: urlPattern, options: .caseInsensitive)
        
        // Get the number of matches for the URL regex pattern
        let numberOfMatches = regex.numberOfMatches(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count))
        
        // If the number of matches is greater than 0, the URL is valid
        return numberOfMatches > 0
    }
}
