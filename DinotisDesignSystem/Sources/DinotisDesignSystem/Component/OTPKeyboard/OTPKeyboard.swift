//
//  OTPKeyboard.swift
//  
//
//  Created by Gus Adi on 07/12/22.
//

import SwiftUI

public struct OTPKeyboard: View {
	@Binding var code: String

	var rows = ["1","2","3","4","5","6","7","8","9","","0","delete.left",]

	public init(
		code: Binding<String>
	) {
		self._code = code
	}

	public var body: some View {

		HStack(alignment: .center) {

			Spacer()

				LazyVGrid(
					columns: Array(
						repeating: GridItem(
							.flexible(),
							spacing: 10
						),
						count: 3
					),
					spacing: 10
				) {

					ForEach(rows,id:\.self) {value in

						Button(action: {

							buttonAction(value:value)}
						) {

							HStack {

								Spacer()

									if value == "delete.left" {

										Image(systemName:value)
											.font(.system(size: 20, weight: .bold, design: .rounded))
											.foregroundColor(.DinotisDefault.black1)

									} else {

										Text(value)

											.font(.robotoBold(size: 20))
											.foregroundColor(.DinotisDefault.black1)

									}

								Spacer()

							}
							.padding()
							.background(
								RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(value == "" ? .clear : .DinotisDefault.secondary.opacity(0.05))
							)

						}
						.buttonStyle(.plain)

					}

				}

			Spacer()

			}
			.padding()

			.background(
                Color.DinotisDefault.white.edgesIgnoringSafeArea(.vertical)
			)

	}

	func buttonAction(value:String) {
		if value == "delete.left" && code != ""{

			code.removeLast()

		}

		if value != "delete.left"{

			if code.count < 6 {

				code.append(contentsOf: value)

			}

		}

	}
}

struct OTPKeyboard_Previews: PreviewProvider {
	static var previews: some View {
		OTPKeyboard(code: .constant(""))
	}
}


