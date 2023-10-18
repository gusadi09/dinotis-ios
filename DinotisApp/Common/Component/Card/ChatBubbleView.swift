//
//  ChatBubbleView.swift
//  DinotisApp
//
//  Created by Gus Adi on 06/10/22.
//

import SwiftUI
import DinotisDesignSystem

struct ChatBubbleView: View {

	let sender: String
	let message: String
	let date: Date
	let isSender: Bool

    var body: some View {
		VStack(alignment: .leading, spacing: 12) {
			HStack {
				if !isSender {
					Text(sender)
						.font(.robotoBold(size: 12))
                        .lineLimit(1)
						.foregroundColor(isSender ? .white : .white)
						.multilineTextAlignment(.leading)
				}
			}

			Text(message)
				.font(.robotoRegular(size: 12))
				.foregroundColor(isSender ? .black : .white)
				.multilineTextAlignment(isSender ? .trailing : .leading)
            
            VStack(alignment: .trailing) {
                Rectangle()
                    .foregroundColor(isSender ? .secondaryViolet : .DinotisDefault.primary)
                
                    .frame(maxWidth: 256, maxHeight: 0.5)
                Text(date.toStringFormat(with: .HHmm))
                    .font(.robotoRegular(size: 10))
                    .foregroundColor(isSender ? .black : .white)
            }
		}
        .frame(maxWidth: 256)
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
		.background(
			RoundedCorner(radius: 20, corners: isSender ? [.bottomLeft, .topLeft, .topRight] : [.bottomRight, .topLeft, .topRight])
				.foregroundColor(isSender ? .secondaryViolet : .DinotisDefault.primary)
		)
    }
}

struct ChatBubbleView_Previews: PreviewProvider {
    static var previews: some View {
        LazyVStack {
            ChatBubbleView(sender: "Test", message: "Dolor ipsum", date: Date(), isSender: false)
            
            ChatBubbleView(sender: "Test", message: "Dolor ipsum", date: Date(), isSender: true)
        }
    }
}
