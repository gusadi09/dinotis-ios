//
//  ProfileImageContainer.swift
//  DinotisApp
//
//  Created by Gus Adi on 30/09/21.
//

import SwiftUI
import DinotisData

struct ProfileImageContainer: View {
	@Binding var profilePhoto: String?
	@Binding var name: String?
	@State var width: Double
	@State var height: Double
	
	var isChatBox: Bool = false
	
	private let config = Configuration.shared
	
	var body: some View {
        if isChatBox {
			ImageLoader(
				url: (profilePhoto != nil ?
					  "\(config.environment.openURL)" + profilePhoto.orEmpty() : "https://ui-avatars.com/api/?background=random&format=png&name=" +
					  name.orEmpty().replacingOccurrences(of: " ", with: "+")
				),
				width: width,
				height: height
			)
			.clipShape(Circle())
		} else {
			if profilePhoto?.prefix(5) != "https" {
				ImageLoader(
					url: (
						profilePhoto != nil ?
						  "\(config.environment.baseURL)/uploads/" + (profilePhoto.orEmpty()) : "https://ui-avatars.com/api/?background=random&format=png&name=" +
						  name.orEmpty().replacingOccurrences(of: " ", with: "+")
					),
					width: width,
					height: height
				)
				.clipShape(Circle())
			} else if name.orEmpty().isEmpty && profilePhoto.orEmpty().isEmpty {
				ImageLoader(
					url: "https://www.kindpng.com/picc/m/105-1055656_account-user-profile-avatar-avatar-user-profile-icon.png",
					width: width,
					height: height
				)
				.clipShape(Circle())
			} else {
				ImageLoader(
					url: (
						profilePhoto != nil ?
						profilePhoto.orEmpty() : "https://ui-avatars.com/api/?background=random&format=png&name=" + name.orEmpty().replacingOccurrences(of: " ", with: "+")
					),
					width: width,
					height: height
				)
				.clipShape(Circle())
				
			}
		}
	}
}

struct ProfileImageContainer_Previews: PreviewProvider {
	static var previews: some View {
		ProfileImageContainer(profilePhoto: .constant("2c57a024108105a8b9fb487921c810c4905.png"), name: .constant("aa"), width: 55, height: 55)
	}
}
