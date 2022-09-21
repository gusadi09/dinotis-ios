//
//  FieldValidator.swift
//  DinotisApp
//
//  Created by Gus Adi on 15/09/21.
//

import Foundation

class FieldValidator {
	static let shared = FieldValidator()
	
	func skipValidation() -> (valid: Bool, message: String) {
		return (true, "")
	}
	
	func isEmailValid(email: String) -> (valid: Bool, message: String) {
		var status = false
		var message = ""
		
		let emailTestValid = NSPredicate(format: "SELF MATCHES %@",
																		 "^([a-zA-Z0-9]+(?:[.-]?[a-zA-Z0-9]+)*@[a-zA-Z0-9]+(?:[.-]?[a-zA-Z0-9]+)*\\.[a-zA-Z]{2,7})$")
		
		if emailTestValid.evaluate(with: email) {
			status = true
		} else {
			message = NSLocalizedString("email_error", comment: "")
		}
		
		return (status, message)
	}
	
	func isPasswordValid(password: String) -> (valid: Bool, message: String) {
		var status = false
		var message = ""
		
		let passwordTestValid = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-zA-Z0-9]).{6,}$")
		
		if passwordTestValid.evaluate(with: password) {
			status = true
		} else {
			message = NSLocalizedString("password_short", comment: "")
		}
		
		return (status, message)
	}
	
	func isPasswordConfirmationMatch(password: String, confirmation: String) -> (valid: Bool, message: String) {
		var status = false
		var message = ""
		
		if password == confirmation {
			status = true
		} else {
			message = NSLocalizedString("password_not_match", comment: "")
		}
		
		return (status, message)
	}
}
