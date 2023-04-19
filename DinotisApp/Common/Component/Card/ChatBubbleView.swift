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
		VStack(alignment: isSender ? .trailing : .leading, spacing: 15) {
			HStack {
				if isSender {

                    Text(DateUtils.dateFormatter(date, forFormat: .negotiationBubbleChat))
						.font(.robotoRegular(size: 10))
						.foregroundColor(isSender ? .white : .DinotisDefault.primary)
						.multilineTextAlignment(.leading)

					Spacer()

					Text(LocaleText.meText)
						.font(.robotoBold(size: 12))
						.foregroundColor(isSender ? .white : .DinotisDefault.primary)
						.multilineTextAlignment(.trailing)

				} else {
					Text(sender)
						.font(.robotoBold(size: 12))
						.foregroundColor(isSender ? .white : .DinotisDefault.primary)
						.multilineTextAlignment(.leading)

					Spacer()

                    Text(DateUtils.dateFormatter(date, forFormat: .negotiationBubbleChat))
						.font(.robotoRegular(size: 10))
						.foregroundColor(isSender ? .white : .DinotisDefault.primary)
						.multilineTextAlignment(.trailing)
				}
			}

			Text(message)
				.font(.robotoRegular(size: 12))
				.foregroundColor(isSender ? .white : .DinotisDefault.primary)
				.multilineTextAlignment(isSender ? .trailing : .leading)
		}
		.padding()
		.background(
			RoundedCorner(radius: 20, corners: isSender ? [.bottomLeft, .topLeft, .topRight] : [.bottomRight, .topLeft, .topRight])
				.foregroundColor(isSender ? .DinotisDefault.primary : .secondaryViolet)
		)
    }
}

struct ChatBubbleView_Previews: PreviewProvider {
    static var previews: some View {
		ChatBubbleView(sender: "", message: "", date: Date(), isSender: false)
    }
}
