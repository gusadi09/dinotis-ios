//
//  DinotisSecondaryButton.swift
//  
//
//  Created by Gus Adi on 30/11/22.
//

import SwiftUI

public struct DinotisSecondaryButton: View {
	private let action: () -> Void
	private let textColor: Color
	private let bgColor: Color
	private let strokeColor: Color
	private let text: String
	private let type: ButtonType
    private let height: CGFloat?

	public init(
		text: String,
		type: ButtonType,
        height: CGFloat? = nil,
		textColor: Color,
		bgColor: Color,
		strokeColor: Color,
		_ action: @escaping () -> Void
	) {
		self.text = text
		self.bgColor = bgColor
        self.height = height
		self.textColor = textColor
		self.action = action
		self.strokeColor = strokeColor
		self.type = type
	}

	public var body: some View {
        switch type {
        case .wrappedContent:
            if let height = height {
                Button(action: action) {
                    Text(text)
                        .font(.robotoBold(size: 14))
                        .foregroundColor(textColor)
                        .padding(.horizontal)
                        .frame(height: height)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(bgColor)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(strokeColor, lineWidth: 1)
                        )
                        .contentShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
            } else {
                Button(action: action) {
                    Text(text)
                        .font(.robotoBold(size: 14))
                        .foregroundColor(textColor)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(bgColor)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(strokeColor, lineWidth: 1)
                        )
                        .contentShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
            }
            
        case .adaptiveScreen:
            if let height = height {
                Button(action: action) {
                    HStack {
                        Spacer()
                        
                        Text(text)
                            .font(.robotoBold(size: 14))
                            .foregroundColor(textColor)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .frame(height: height)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(bgColor)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(strokeColor, lineWidth: 1)
                    )
                    .contentShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
            } else {
                Button(action: action) {
                    HStack {
                        Spacer()
                        
                        Text(text)
                            .font(.robotoBold(size: 14))
                            .foregroundColor(textColor)
                        
                        Spacer()
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(bgColor)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(strokeColor, lineWidth: 1)
                    )
                    .contentShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
            }
            
        case .mini:
            if let height = height {
                Button(action: action) {
                    Text(text)
                        .font(.robotoBold(size: 12))
                        .foregroundColor(textColor)
                        .padding(.horizontal, 10)
                        .frame(height: height)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(bgColor)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(strokeColor, lineWidth: 1)
                        )
                        .contentShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
            } else {
                Button(action: action) {
                    Text(text)
                        .font(.robotoBold(size: 12))
                        .foregroundColor(textColor)
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(bgColor)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(strokeColor, lineWidth: 1)
                        )
                        .contentShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
            }
            
		case .fixed(let width):
            if let height = height {
                Button(action: action) {
                    Text(text)
                        .font(.robotoBold(size: 14))
                        .foregroundColor(textColor)
                        .frame(width: width, height: height)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(bgColor)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(strokeColor, lineWidth: 1)
                        )
                        .contentShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
            } else {
                Button(action: action) {
                    Text(text)
                        .font(.robotoBold(size: 14))
                        .foregroundColor(textColor)
                        .padding(.vertical)
                        .frame(width: width)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .foregroundColor(bgColor)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(strokeColor, lineWidth: 1)
                        )
                        .contentShape(RoundedRectangle(cornerRadius: 10))
                }
                .buttonStyle(.plain)
            }
		}

	}
}

struct DinotisSecondaryButton_Previews: PreviewProvider {
    static var previews: some View {
		VStack {
			DinotisSecondaryButton(
				text: "Preview Button",
				type: .wrappedContent,
				textColor: .blue,
				bgColor: .blue.opacity(0.1),
				strokeColor: .blue,
				{}
			)
			.padding()

			DinotisSecondaryButton(
				text: "Preview Button",
				type: .adaptiveScreen,
				textColor: .blue,
				bgColor: .blue.opacity(0.1),
				strokeColor: .blue,
				{}
			)
			.padding()
		}
    }
}
