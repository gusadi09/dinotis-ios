//
//  DinotisImageLoader.swift
//  
//
//  Created by Gus Adi on 09/12/22.
//

import DinotisData
import SwiftUI
import SDWebImage
import SDWebImageSwiftUI
import SDWebImageSVGCoder

public struct DinotisImageLoader: View {

	private let urlString: String
	private let width: CGFloat?
	private let height: CGFloat?

	@State private var isFailure = false

	public init(urlString: String, width: CGFloat? = nil, height: CGFloat? = nil) {
		self.urlString = urlString
		self.width = width
		self.height = height

		SDImageCodersManager.shared.addCoder(SDImageSVGCoder.shared)
	}

	public var body: some View {
		if let width = width, let height = height {
			if urlString.contains(".svg") {
				if isFailure {
					Image.generalEmptyImage
						.resizable()
						.scaledToFit()
						.frame(width: width, height: height)
				} else {
					AnimatedImage(
						url: urlString.toURL()
					)
                    .placeholder(content: {
                        Color.gray
                            .frame(minWidth: width, minHeight: height)
                    })
					.resizable()
					.customLoopCount(1)
					.playbackRate(2.0)
					.onFailure { _ in
						isFailure.toggle()
					}
					.indicator(.activity)
					.transition(.fade(duration: 0.5))
					.scaledToFit()
					.frame(width: width, height: height)
					.background(
                        Color.gray
							.frame(width: width, height: height)
					)
				}
			} else {
				if isFailure {
					Image.generalEmptyImage
						.resizable()
						.scaledToFit()
						.frame(width: width, height: height)
				} else {
					WebImage(
						url: urlString.toURL()
					)
                    .placeholder(content: {
                        Color.gray
                            .frame(minHeight: height)
                    })
					.resizable()
					.customLoopCount(1)
					.playbackRate(2.0)
					.onFailure { _ in
						isFailure.toggle()
					}
					.indicator(.activity)
					.transition(.fade(duration: 0.5))
					.scaledToFit()
					.frame(width: width, height: height)
					.background(
                        Color.gray
							.frame(width: width, height: height)
					)
				}
			}
		} else if let width = width {
			if urlString.contains(".svg") {
				if isFailure {
					Image.generalEmptyImage
						.resizable()
						.scaledToFit()
						.frame(width: width)
				} else {
					AnimatedImage(
						url: urlString.toURL()
					)
                    .placeholder(content: {
                        Color.gray
                            .frame(minHeight: 120)
                    })
					.resizable()
					.customLoopCount(1)
					.playbackRate(2.0)
					.onFailure { _ in
						isFailure.toggle()
					}
					.indicator(.activity)
					.transition(.fade(duration: 0.5))
					.scaledToFit()
					.frame(width: width)
					.background(
                        Color.gray
							.frame(width: width)
					)
				}
			} else {
				if isFailure {
					Image.generalEmptyImage
						.resizable()
						.scaledToFit()
						.frame(width: width)
				} else {
					WebImage(
						url: urlString.toURL()
					)
                    .placeholder(content: {
                        Color.gray
                            .frame(minHeight: 120)
                    })
					.resizable()
					.customLoopCount(1)
					.playbackRate(2.0)
					.onFailure { _ in
						isFailure.toggle()
					}
					.indicator(.activity)
					.transition(.fade(duration: 0.5))
					.scaledToFit()
					.frame(width: width)
					.background(
                        Color.gray
							.frame(width: width)
					)
				}
			}
		} else if let height = height {
			if urlString.contains(".svg") {
				if isFailure {
					Image.generalEmptyImage
						.resizable()
						.scaledToFit()
						.frame(height: height)
				} else {
					AnimatedImage(
						url: urlString.toURL()
					)
                    .placeholder(content: {
                        Color.gray
                            .frame(minHeight: height)
                    })
					.resizable()
					.customLoopCount(1)
					.playbackRate(2.0)
					.onFailure { _ in
						isFailure.toggle()
					}
					.indicator(.activity)
					.transition(.fade(duration: 0.5))
					.scaledToFit()
					.frame(height: height)
					.background(
                        Color.gray
							.frame(height: height)
					)
				}
			} else {
				if isFailure {
					Image.generalEmptyImage
						.resizable()
						.scaledToFit()
						.frame(height: height)
				} else {
					WebImage(
						url: urlString.toURL()
					)
                    .placeholder(content: {
                        Color.gray
                            .frame(minHeight: height)
                    })
					.resizable()
					.customLoopCount(1)
					.playbackRate(2.0)
					.onFailure { _ in
						isFailure.toggle()
					}
					.indicator(.activity)
					.transition(.fade(duration: 0.5))
					.scaledToFit()
					.frame(height: height)
					.background(
                        Color.gray
							.frame(height: height)
					)
				}
			}
		} else {
			if urlString.contains(".svg") {
				if isFailure {
					Image.generalEmptyImage
						.resizable()
						.scaledToFit()
				} else {
					AnimatedImage(
						url: urlString.toURL()
					)
                    .placeholder(content: {
                        Color.gray
                            .frame(minHeight: 120)
                    })
					.resizable()
					.customLoopCount(1)
					.playbackRate(2.0)
					.onFailure { _ in
						isFailure.toggle()
					}
					.indicator(.activity)
					.transition(.fade(duration: 0.5))
					.scaledToFit()
					.background(
						Image("")
							.resizable()
							.scaledToFit()
							.overlay(
								ProgressView()
									.progressViewStyle(.circular)
							)
							.background(
								Rectangle()
									.foregroundColor(.gray)
							)
					)
				}
			} else {
				if isFailure {
					Image.generalEmptyImage
						.resizable()
						.scaledToFit()

				} else {
					WebImage(
						url: urlString.toURL()
					)
                    .placeholder(content: {
                        Color.gray
                            .frame(minHeight: 120)
                    })
					.resizable()
					.customLoopCount(1)
					.playbackRate(2.0)
					.onFailure { _ in
						isFailure.toggle()
					}
					.indicator(.activity)
					.transition(.fade(duration: 0.5))
					.scaledToFill()
					.background(
						Image("")
							.resizable()
							.scaledToFit()
							.overlay(
								ProgressView()
									.progressViewStyle(.circular)
							)
							.background(
								Rectangle()
									.foregroundColor(.gray)
							)
					)
				}
			}
		}

	}
}

struct DinotisImageLoader_Previews: PreviewProvider {
	static var previews: some View {
		DinotisImageLoader(urlString: "https://i2.wp.com/beebom.com/wp-content/uploads/2016/01/Reverse-Image-Search-Engines-Apps-And-Its-Uses-2016.jpg", width: 900, height: 500)
			.frame(width: 1000, height: 1000, alignment: .center)
	}
}
