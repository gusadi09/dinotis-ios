//
//  HeaderView.swift
//  
//
//  Created by Gus Adi on 08/12/22.
//

import SwiftUI

public enum HeaderType: Equatable {
	case imageHeader(Image, CGFloat)
	case textHeader
}

public struct HeaderView<LeadingContent: View, TrailingContent: View>: View {

	private let type: HeaderType
	private let title: String
	private let headerColor: Color
	private let textColor: Color
	private let leadingButton: LeadingContent
	private let trailingButton: TrailingContent

	public init(
		type: HeaderType = .textHeader,
		title: String,
		headerColor: Color = .DinotisDefault.baseBackground,
		textColor: Color = .DinotisDefault.black1,
		@ViewBuilder leadingButton: () -> LeadingContent = { Rectangle().foregroundColor(.clear).scaledToFit().frame(height: 30) },
		@ViewBuilder trailingButton: () -> TrailingContent = { Rectangle().foregroundColor(.clear).scaledToFit().frame(height: 30) }
	) {
		self.type = type
		self.title = title
		self.headerColor = headerColor
		self.textColor = textColor
		self.leadingButton = leadingButton()
		self.trailingButton = trailingButton()
	}

	public var body: some View {
        GeometryReader { geo in
            ZStack {
                HStack(spacing: 0) {
                    leadingButton
                    
                    Spacer()
                    
                    trailingButton
                }
                
                Group {
                    switch type {
                    case .textHeader:
                        Text(title)
                            .font(.robotoBold(size: 18))
                            .foregroundColor(textColor)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                    case .imageHeader(let image, let size):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(height: size)
                    }
                }
                .frame(width: geo.size.width - 100)
            }
        }
        .frame(height: 36)
		.padding(.horizontal)
		.padding(.top, 15)
		.padding(.bottom, type == .textHeader ? 25 : 15)
		.background(
			headerColor.edgesIgnoringSafeArea(.vertical)
		)
    }
}

struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
		VStack {
			HeaderView(title: "Test")

			Spacer()
		}

		VStack {
			HeaderView(
				title: "Test",
				leadingButton: {
					DinotisElipsisButton(icon: .generalBackIcon, iconColor: .black, bgColor: .white, iconSize: 12, {})
						.shadow(radius: 10)
				}
			)

			Spacer()
		}

		VStack {
			HeaderView(
				type: .imageHeader(.generalDinotisImage, 25),
				title: "Test",
				leadingButton: {
					DinotisElipsisButton(icon: .generalBackIcon, iconColor: .black, bgColor: .white, iconSize: 12, {})
						.shadow(radius: 10)
				}
			)

			Spacer()
		}
    }
}
