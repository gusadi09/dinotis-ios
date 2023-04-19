//
//  AnnouncementView.swift
//  DinotisApp
//
//  Created by Gus Adi on 25/04/22.
//

import SwiftUI
import SDWebImageSwiftUI
import DinotisData

struct AnnouncementView: View {

	@ObservedObject var state = StateObservable.shared
	@Binding var items: AnnouncementData
	var action: () -> Void

	private let config = Configuration.shared

	var body: some View {
		GeometryReader { proxy in
			ZStack {
				Color.black
					.edgesIgnoringSafeArea(.all)
					.opacity(0.5)

				ZStack(alignment: .topTrailing) {
					WebImage(
						url: (
							items.imgUrl.orEmpty()
						).toURL()
					)
					.resizable()
					.customLoopCount(1)
					.playbackRate(2.0)
					.placeholder {
						RoundedRectangle(cornerRadius: 18)
							.foregroundColor(Color(.systemGray3))
					}
					.indicator(.activity)
					.transition(.fade(duration: 0.5))
					.scaledToFit()
					.frame(maxWidth: proxy.size.width/1.1)
					.padding(20)
					.onTapGesture {
						guard let url = URL(string: items.url.orEmpty()) else { return }
						UIApplication.shared.open(url)
					}
					
					Button {
						withAnimation {
							action()
						}
					} label: {
						Image(systemName: "xmark.circle.fill")
							.resizable()
							.scaledToFit()
							.frame(height: 28)
							.foregroundColor(Color(.systemGray4))
					}

				}
				.padding()
			}
			.opacity(!state.isAnnounceShow ? 1 : 0)
		}
	}
}

struct AnnouncementView_Previews: PreviewProvider {
    static var previews: some View {
			AnnouncementView(
				items: .constant(
					AnnouncementData(
						id: 1,
						title: "Testing",
						imgUrl: "https://api.dinotis.com/api/v1/uploads/054e3cdb10d7ee98255f825117254610b9.png",
						url: "",
						caption: "",
						description: "",
						createdAt: Date(),
						updatedAt: Date()
					)
				),
				action: { }
			)
		}
}
