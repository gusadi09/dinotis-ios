//
//  String+isValidEmail.swift
//  DinotisApp
//
//  Created by Gus Adi on 08/12/21.
//

import Foundation
import UIKit

extension String {
	func isValidEmail() -> Bool {
		let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
		
		let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
		return emailPred.evaluate(with: self)
	}
	
	func isValidUsername() -> Bool {
		let usernameRegEx = "\\A\\w{3,}\\z"
		
		let userPred = NSPredicate(format: "SELF MATCHES %@", usernameRegEx)
		return userPred.evaluate(with: self)
	}
    
    func verifyUrl() -> Bool {
        guard let url = URL(string: self) else {
            return false
        }

        return UIApplication.shared.canOpenURL(url)
    }
}
