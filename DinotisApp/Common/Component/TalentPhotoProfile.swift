//
//  TalentPhotoProfile.swift
//  DinotisApp
//
//  Created by Gus Adi on 17/04/22.
//

import SwiftUI
import SDWebImageSwiftUI

struct TalentPhotoProfile: View {
	@Binding var profilePhoto: String?
	@Binding var name: String?
	@State var width: Double
	@State var height: Double
	
	var isChatBox: Bool = false
	
	private let config = Configuration.shared
	
	var body: some View {
		if isChatBox {
			WebImage(
				url: (profilePhoto != nil ?
							"\(config.environment.openURL)" + profilePhoto.orEmpty() : "https://avatar.oxro.io/avatar.svg?name=" +
							(name?.replacingOccurrences(of: " ", with: "+")).orEmpty()).toURL()
			)
			.resizable()
			.customLoopCount(1)
			.playbackRate(2.0)
			.placeholder {Rectangle().foregroundColor(Color(.systemGray3))}
			.indicator(.activity)
			.transition(.fade(duration: 0.5))
			.scaledToFill()
			.frame(width: width, height: height)
			.clipShape(Rectangle())
		} else {
			if profilePhoto?.prefix(5) != "https" {
				WebImage(
					url: (profilePhoto != nil ?
								"\(config.environment.baseURL)/uploads/" + (profilePhoto.orEmpty()) : "https://avatar.oxro.io/avatar.svg?name=" +
								(name?.replacingOccurrences(of: " ", with: "+")).orEmpty()).toURL()
				)
				.resizable()
				.customLoopCount(1)
				.playbackRate(2.0)
				.placeholder {Rectangle().foregroundColor(Color(.systemGray3))}
				.indicator(.activity)
				.transition(.fade(duration: 0.5))
				.scaledToFill()
				.frame(width: width, height: height)
				.clipShape(Rectangle())
			} else if name.orEmpty().isEmpty && profilePhoto.orEmpty().isEmpty {
				WebImage(
					url: "https://www.kindpng.com/picc/m/105-1055656_account-user-profile-avatar-avatar-user-profile-icon.png".toURL()
				)
				.resizable()
				.customLoopCount(1)
				.playbackRate(2.0)
				.placeholder {Rectangle().foregroundColor(Color(.systemGray3))}
				.indicator(.activity)
				.transition(.fade(duration: 0.5))
				.scaledToFill()
				.frame(width: width, height: height)
				.clipShape(Rectangle())
			} else {
				WebImage(
					url: (
						profilePhoto != nil ?
						profilePhoto.orEmpty() : "https://avatar.oxro.io/avatar.svg?name=" + (name?.replacingOccurrences(of: " ", with: "+")).orEmpty()
					).toURL()
				)
				.resizable()
				.customLoopCount(1)
				.playbackRate(2.0)
				.placeholder {Rectangle().foregroundColor(Color(.systemGray3))}
				.indicator(.activity)
				.transition(.fade(duration: 0.5))
				.scaledToFill()
				.frame(width: width, height: height)
				.clipShape(Rectangle())
			}
		}
	}
}

struct TalentPhotoProfile_Previews: PreviewProvider {
	static var previews: some View {
		ProfileImageContainer(profilePhoto: .constant("f2105c1cc00dae3bcaf4d7102027480c44.png"), name: .constant("aa"), width: 55, height: 55)
	}
}
