//
//  ImageLoader.swift
//  DinotisApp
//
//  Created by Gus Adi on 16/09/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct ImageLoader: View {

	let url: String
	let width: CGFloat
	let height: CGFloat

    var body: some View {
		if #available(iOS 16.0, *) {
			AsyncImage(url: url.toURL()) { phase in
				if let image = phase.image {
					image
						.resizable()
						.scaledToFill()
						.frame(width: width, height: height)
						
				} else if phase.error != nil {

					HStack {
						Image(systemName: "person.crop.circle.badge.exclamationmark")
							.foregroundColor(.white)
							.padding()
					}
					.foregroundColor(Color(.systemGray3))
					.frame(width: width, height: height)
					.background(
						Rectangle().foregroundColor(Color(.systemGray3))
					)

				} else {

					ProgressView()
						.progressViewStyle(.circular)
						.foregroundColor(Color(.systemGray3))
						.frame(width: width, height: height)
						.background(
							Rectangle()
								.foregroundColor(Color(.systemGray3))

						)
				}
			}

		} else {
			WebImage(
				url: url.toURL()
			)
			.resizable()
			.customLoopCount(1)
			.playbackRate(2.0)
			.placeholder {Rectangle().foregroundColor(Color(.systemGray3))}
			.indicator(.activity)
			.transition(.fade(duration: 0.5))
			.scaledToFill()
			.frame(width: width, height: height)
			.clipShape(Circle())
		}
    }
}

struct ImageLoader_Previews: PreviewProvider {
    static var previews: some View {
		ImageLoader(url: "https://swiftanytime-content.s3.ap-south-1.amazonaws.com/SwiftUI-Beginner/Async-Image/TestImage.jpeg", width: 40, height: 40)
    }
}
