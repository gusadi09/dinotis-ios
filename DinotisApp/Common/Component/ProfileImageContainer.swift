//
//  ProfileImageContainer.swift
//  DinotisApp
//
//  Created by Gus Adi on 30/09/21.
//

import SwiftUI
import DinotisData

struct ProfileImageContainer<S: Shape>: View {
	@Binding var profilePhoto: String?
	@Binding var name: String?
	var width: Double
	var height: Double
    
    let shape: S
	var isChatBox: Bool = false
	
	private let config = Configuration.shared
    
    init(profilePhoto: Binding<String?>, name: Binding<String?>, width: Double, height: Double, shape: S = Circle(), isChatBox: Bool = false) {
        self._profilePhoto = profilePhoto
        self._name = name
        self.width = width
        self.height = height
        self.shape = shape
        self.isChatBox = isChatBox
    }
	
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
			.clipShape(shape)
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
				.clipShape(shape)
			} else if name.orEmpty().isEmpty && profilePhoto.orEmpty().isEmpty {
				ImageLoader(
					url: "https://www.kindpng.com/picc/m/105-1055656_account-user-profile-avatar-avatar-user-profile-icon.png",
					width: width,
					height: height
				)
				.clipShape(shape)
			} else {
				ImageLoader(
					url: (
						profilePhoto != nil ?
						profilePhoto.orEmpty() : "https://ui-avatars.com/api/?background=random&format=png&name=" + name.orEmpty().replacingOccurrences(of: " ", with: "+")
					),
					width: width,
					height: height
				)
				.clipShape(shape)
				
			}
		}
	}
}

struct ProfileImageContainer_Previews: PreviewProvider {
	static var previews: some View {
        ProfileImageContainer(profilePhoto: .constant("2c57a024108105a8b9fb487921c810c4905.png"), name: .constant("aa"), width: 55, height: 55, shape: Circle())
	}
}
