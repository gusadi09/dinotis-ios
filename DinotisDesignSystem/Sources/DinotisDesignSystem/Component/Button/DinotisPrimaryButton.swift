//
//  DinotisPrimaryButton.swift
//  DinotisDesignSystem
//
//  Created by Gus Adi on 30/11/22.
//

import SwiftUI

public enum ButtonType {
	case wrappedContent
	case adaptiveScreen
	case mini
	case fixed(CGFloat)
}

public struct DinotisPrimaryButton: View {

	private let action: () -> Void
	private let textColor: Color
    private let height: CGFloat?
	private let bgColor: Color
	private let text: String
	private let type: ButtonType
    @Binding var isLoading: Bool

	public init(
		text: String,
		type: ButtonType,
        height: CGFloat? = nil,
		textColor: Color,
		bgColor: Color,
        isLoading: Binding<Bool> = .constant(false),
		_ action: @escaping () -> Void
	) {
		self.text = text
		self.bgColor = bgColor
        self.height = height
		self.textColor = textColor
		self.action = action
		self.type = type
        self._isLoading = isLoading
	}

	public var body: some View {
		switch type {
		case .wrappedContent:
            if let height = height {
                Button(action: action) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(.circular)
                    } else {
                        Text(text)
                            .font(.robotoBold(size: 14))
                            .foregroundColor(textColor)
                            .padding(.horizontal)
                            .frame(height: height)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(bgColor)
                            )
                    }
                }
                .buttonStyle(.plain)
            } else {
                Button(action: action) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(.circular)
                    } else {
                        Text(text)
                            .font(.robotoBold(size: 14))
                            .foregroundColor(textColor)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(bgColor)
                            )
                    }
                }
                .buttonStyle(.plain)
            }

		case .adaptiveScreen:
            if let height = height {
                Button(action: action) {
                    HStack {
                        Spacer()
                        
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(.circular)
                        } else {
                            Text(text)
                                .font(.robotoBold(size: 14))
                                .foregroundColor(textColor)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .frame(height: height)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(bgColor)
                    )
                }
                .buttonStyle(.plain)
            } else {
                Button(action: action) {
                    HStack {
                        Spacer()
                        
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(.circular)
                        } else {
                            Text(text)
                                .font(.robotoBold(size: 14))
                                .foregroundColor(textColor)
                        }
                        
                        Spacer()
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .foregroundColor(bgColor)
                    )
                }
                .buttonStyle(.plain)
            }

		case .mini:
            if let height = height {
                Button(action: action) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(.circular)
                    } else {
                        Text(text)
                            .font(.robotoBold(size: 12))
                            .foregroundColor(textColor)
                            .padding(.horizontal, 10)
                            .frame(height: height)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(bgColor)
                            )
                    }
                }
                .buttonStyle(.plain)
            } else {
                Button(action: action) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(.circular)
                    } else {
                        Text(text)
                            .font(.robotoBold(size: 12))
                            .foregroundColor(textColor)
                            .padding(10)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(bgColor)
                            )
                    }
                }
                .buttonStyle(.plain)
            }
            
		case .fixed(let width):
            if let height = height {
                Button(action: action) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(.circular)
                    } else {
                        Text(text)
                            .font(.robotoBold(size: 14))
                            .foregroundColor(textColor)
                            .frame(width: width, height: height)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(bgColor)
                            )
                    }
                }
                .buttonStyle(.plain)
            } else {
                Button(action: action) {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(.circular)
                    } else {
                        Text(text)
                            .font(.robotoBold(size: 14))
                            .foregroundColor(textColor)
                            .padding(.vertical)
                            .frame(width: width)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(bgColor)
                            )
                    }
                }
                .buttonStyle(.plain)
            }
		}

	}
}

struct DinotisPrimaryButton_Preview: PreviewProvider {
	static var previews: some View {
		VStack {
			DinotisPrimaryButton(
				text: "Preview Button",
				type: .wrappedContent,
				textColor: .white,
				bgColor: .blue, {}
			)
			.padding()

			DinotisPrimaryButton(
				text: "Preview Button",
				type: .adaptiveScreen,
				textColor: .white,
				bgColor: .blue, {}
			)
			.padding()
		}
	}
}
