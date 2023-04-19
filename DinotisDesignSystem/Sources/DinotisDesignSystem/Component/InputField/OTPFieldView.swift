//
//  OTPFieldView.swift
//  
//
//  Created by Gus Adi on 07/12/22.
//

import SwiftUI

public struct OTPFieldView: View {

	let code: String
	let isSelected: Bool

	public init(code: String, isSelected: Bool = false) {
		self.code = code
		self.isSelected = isSelected
	}

    public var body: some View {
        Text(code)
			.font(.robotoBold(size: 16))
			.foregroundColor(.DinotisDefault.black1)
			.frame(width: 39, height: 43)
			.background(
				RoundedRectangle(cornerRadius: 5)
					.foregroundColor(.DinotisDefault.white)
			)
			.overlay(
				RoundedRectangle(cornerRadius: 5)
					.stroke(isSelected ? Color.DinotisDefault.secondary : Color.DinotisDefault.black3, lineWidth: 1)
			)

    }
}

public struct OTPView: View {

	@Binding var allCode: String
	@Binding var errorText: String?

	public init(allCode: Binding<String>, errorText: Binding<String?>) {
		self._allCode = allCode
		self._errorText = errorText
	}

	public var body: some View {

		HStack {
			Spacer()

			VStack(alignment: .leading, spacing: 10) {
				HStack(spacing: 8) {
					ForEach(0..<6, id: \.self) { idx in
						OTPFieldView(code: getCode(at: idx), isSelected: allCode.count == idx)
					}
				}

				if let error = errorText {
					Text(error)
						.font(.robotoMedium(size: 10))
						.foregroundColor(.DinotisDefault.red)
						.multilineTextAlignment(.leading)
				}
			}

			Spacer()
		}
	}

	func getCode(at index: Int) -> String {
		if allCode.count > index {
			let start = allCode.startIndex
			let current = allCode.index(start, offsetBy: index)

			return String(allCode[current])
		}

		return ""
	}
}

struct OTPFieldView_Previews: PreviewProvider {
    static var previews: some View {
		OTPView(allCode: .constant("123456"), errorText: .constant("Error"))
			.padding()
			.background(
				Color.DinotisDefault.smokeWhite
			)
    }
}
