//
//  OTPField.swift
//  DinotisApp
//
//  Created by Gus Adi on 22/02/22.
//

import SwiftUI
import Introspect

public struct OTPField: View {
	
	var maxDigits: Int = 6
	
	@State var pin: String = ""
	@State var isDisabled = false
	
	var handler: (String, (Bool) -> Void) -> Void
	
	public var body: some View {
		VStack {
			ZStack {
				HStack(spacing: 10) {
					ForEach(0..<maxDigits, id: \.self) { index in
						ZStack {
							
							RoundedRectangle(cornerRadius: 5)
								.foregroundColor(.white)
								.padding()
								.overlay(
									RoundedRectangle(cornerRadius: 8)
										.stroke(Color(.lightGray), lineWidth: 0.5)
								)
								.frame(width: 40, height: 50)
								.shadow(color: Color.dinotisShadow.opacity(0.25), radius: 30, x: 0, y: 0)
							
							Text(self.getDigits(at: index))
								.font(.montserratBold(size: 25))
								.foregroundColor(.black)
						}
					}
				}
				
				backgroundField
			}
		}
	}
	
	private var backgroundField: some View {
		let boundPin = Binding<String>(get: { self.pin }, set: { newValue in
			self.pin = newValue
		})
		
		return TextField("", text: boundPin, onCommit: submitPin)
			.keyboardType(.numberPad)
			.textContentType(.oneTimeCode)
			.foregroundColor(.clear)
			.accentColor(.clear)
			.introspectTextField { field in
				field.becomeFirstResponder()
			}
			.valueChanged(value: boundPin.wrappedValue) { newValue in
				if newValue.count == maxDigits {
					self.submitPin()
				}
			}
	}
	
	private func submitPin() {
		guard !pin.isEmpty else {
			return
		}
		
		if pin.count == maxDigits {
			isDisabled = true
			
			handler(pin) { isSuccess in
				if !isSuccess {
					pin = ""
					isDisabled = false
				}
			}
		}
	}
	
	private func getDigits(at index: Int) -> String {
		if index >= self.pin.count {
			return ""
		}
		
		return self.pin.digits[index].numberString
	}
}

struct PasscodeField_Previews: PreviewProvider {
	static var previews: some View {
		OTPField { _, _ in }
	}
}
