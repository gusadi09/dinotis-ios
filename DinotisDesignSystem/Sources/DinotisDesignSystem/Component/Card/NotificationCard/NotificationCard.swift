//
//  NotificationCard.swift
//  
//
//  Created by Gus Adi on 21/12/22.
//

import SwiftUI

public struct NotificationCardModel {
	public let title: String?
	public let date: Date?
	public let detail: String?
	public let thumbnail: String?
	public let readAt: Date?
    public let status: String?

	public init(title: String?, date: Date?, detail: String?, thumbnail: String?, readAt: Date?, status: String?) {
		self.title = title
		self.date = date
		self.detail = detail
		self.thumbnail = thumbnail
		self.readAt = readAt
        self.status = status
	}
}

public struct NotificationCard: View {

	private let data: NotificationCardModel
    
    private let action: () -> Void

	public init(data: NotificationCardModel, action: @escaping () -> Void) {
		self.data = data
        self.action = action
	}

    public var body: some View {
		HStack(alignment: .top) {
			if let thumbnail = data.thumbnail {
				DinotisImageLoader(urlString: thumbnail, width: 40, height: 40)
					.clipShape(RoundedRectangle(cornerRadius: 10))
					.overlay(
						RoundedRectangle(cornerRadius: 10)
							.stroke(Color.DinotisDefault.primary, lineWidth: 1)
					)
			} else {
				Image.notificationSolidIcon
					.resizable()
					.scaledToFit()
					.frame(height: 40)
			}

			VStack(alignment: .leading, spacing: 10) {
				Text(data.title.orEmpty())
					.font(.robotoMedium(size: 14))
					.foregroundColor(.black)

				Text(data.date.orCurrentDate().toStringFormat(with: .ddMMMyyyyHHmm))
					.font(.robotoRegular(size: 12))
					.foregroundColor(.DinotisDefault.black2)

				Text(data.detail.orEmpty())
					.font(.robotoRegular(size: 12))
					.foregroundColor(.black)
                
                if data.status.orEmpty() == "collaboration_requested" {
                    Button {
                        action()
                    } label: {
                        Text(LocalizableText.seeInvitation)
                            .font(.robotoBold(size: 12))
                            .foregroundColor(.white)
                            .padding(.vertical, 10)
                            .padding(.horizontal, 15)
                            .background(
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(.DinotisDefault.primary)
                            )
                    }
                    .buttonStyle(.plain)
                }
			}
			.multilineTextAlignment(.leading)

			Spacer()
		}
		.padding()
		.background(
			Group {
				if data.readAt != nil {
					Color.clear
						.edgesIgnoringSafeArea(.all)
				} else {
					Color.DinotisDefault.lightPrimary.edgesIgnoringSafeArea(.all)
				}
			}
		)
    }
}

struct NotificationCard_Previews: PreviewProvider {
    static var previews: some View {
		ScrollView {
			LazyVStack(spacing: 0) {
                NotificationCard(data: NotificationCardModel(title: "Test", date: Date(), detail: "Test", thumbnail: nil, readAt: nil, status: nil)) {
                    
                }
                NotificationCard(data: NotificationCardModel(title: "Test", date: Date(), detail: "Test", thumbnail: nil, readAt: nil, status: "collaboration_requested")) {
                    
                }
			}
		}
    }
}
