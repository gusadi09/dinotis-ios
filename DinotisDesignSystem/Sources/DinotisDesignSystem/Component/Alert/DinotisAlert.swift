//
//  DinotisAlert.swift
//  
//
//  Created by Gus Adi on 08/12/22.
//

import SwiftUI

public struct ButtonProperty {
	let text: String
	let action: () -> Void

	public init(text: String, action: @escaping () -> Void) {
		self.text = text
		self.action = action
	}
}

public struct AlertAttribute {
    public var isError: Bool
    public var title: String
    public var message: String
    public var primaryButton: ButtonProperty
    public var secondaryButton: ButtonProperty?
    
    public init(
        isError: Bool = false,
        title: String = "",
        message: String = "",
        primaryButton: ButtonProperty = ButtonProperty(text: "", action: {}),
        secondaryButton: ButtonProperty? = nil
    ) {
        self.isError = isError
        self.title = title
        self.message = message
        self.primaryButton = primaryButton
        self.secondaryButton = secondaryButton
    }
}

public struct DinotisAlert: ViewModifier {

	@Binding var isPresent: Bool
	private let title: String
	private let isError: Bool
	private let message: String
	private let primaryButton: ButtonProperty
	private let secondaryButton: ButtonProperty?

	public init(
		isPresent: Binding<Bool>,
		title: String,
		isError: Bool,
		message: String,
		primaryButton: ButtonProperty,
		secondaryButton: ButtonProperty? = nil
	) {
		self._isPresent = isPresent
		self.title = title
		self.isError = isError
		self.message = message
		self.primaryButton = primaryButton
		self.secondaryButton = secondaryButton
	}

	public func body(content: Content) -> some View {
		ZStack {
			content

			GeometryReader { geo in
				ZStack {
					Color.black.opacity(0.25).edgesIgnoringSafeArea(.all)

					VStack(spacing: 20) {
						Text(title)
							.font(.robotoBold(size: 16))
							.foregroundColor(isError ? .DinotisDefault.red : .DinotisDefault.primary)
							.multilineTextAlignment(.center)

                        Text(.init(message))
							.font(.robotoRegular(size: 12))
							.foregroundColor(.DinotisDefault.black3)
							.multilineTextAlignment(.center)

						HStack(spacing: 10) {
							if let secondaryButton = secondaryButton {
								DinotisSecondaryButton(
									text: secondaryButton.text,
									type: .fixed(geo.size.width/2.9),
									textColor: .DinotisDefault.black1,
									bgColor: .DinotisDefault.lightPrimary,
									strokeColor: .DinotisDefault.primary
								) {
									withAnimation {
										secondaryButton.action()
										isPresent.toggle()
									}

								}

								DinotisPrimaryButton(
									text: primaryButton.text,
									type: .fixed(geo.size.width/2.9),
									textColor: .white,
									bgColor: .DinotisDefault.primary
								) {
									withAnimation {
										primaryButton.action()
										isPresent.toggle()
									}
								}
							} else {

								DinotisPrimaryButton(
									text: primaryButton.text,
                  type: .fixed(geo.size.width/1.4),
									textColor: .white,
									bgColor: .DinotisDefault.primary
								) {
									withAnimation {
										primaryButton.action()
										isPresent.toggle()
									}
								}
							}


						}
					}
					.padding(.vertical, 25)
					.padding(.horizontal)
					.frame(width: geo.size.width/1.2)
					.background(
						RoundedRectangle(cornerRadius: 8)
							.foregroundColor(.white)
					)
					.padding()
          .scaleEffect(isPresent ? 1 : 0)
				}
			}
			.opacity(isPresent ? 1 : 0)
      .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isPresent)
		}
	}
}

struct DintoisAlertPreview: View {
    @State var isPresent = false
    
    var body: some View {
        VStack {
            Button {
                isPresent.toggle()
            } label: {
                Text("Show Alert")
            }
            .buttonStyle(.bordered)
        }
        .dinotisAlert(isPresent: $isPresent, title: "Test", isError: false, message: "Test", primaryButton: .init(text: "OK", action: {}), secondaryButton: .init(text: "Cancel", action: {}))
    }
}

struct DinotisAlert_Previews: PreviewProvider {
	static var previews: some View {
    DintoisAlertPreview()
	}
}

public extension View {
	func dinotisAlert(
		isPresent: Binding<Bool>,
		title: String,
		isError: Bool,
		message: String,
		primaryButton: ButtonProperty,
		secondaryButton: ButtonProperty? = nil
	) -> some View {
		return modifier(
			DinotisAlert(
				isPresent: isPresent,
				title: title,
				isError: isError,
				message: message,
				primaryButton: primaryButton,
				secondaryButton: secondaryButton
			)
		)
	}
}
