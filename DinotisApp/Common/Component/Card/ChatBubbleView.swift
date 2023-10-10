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
		LazyVStack(alignment: .leading, spacing: 15) {
			HStack {
				if !isSender {
					Text(sender)
						.font(.robotoBold(size: 12))
						.foregroundColor(isSender ? .white : .white)
						.multilineTextAlignment(.leading)
				}
			}

			Text(message)
				.font(.robotoRegular(size: 12))
				.foregroundColor(isSender ? .black : .white)
				.multilineTextAlignment(isSender ? .trailing : .leading)
            
            HStack {
                Spacer()
                
                Text(date.toStringFormat(with: .HHmm))
                    .font(.robotoRegular(size: 10))
                    .foregroundColor(isSender ? .black : .white)
            }
		}
		.padding()
        .frame(maxWidth: 256)
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
