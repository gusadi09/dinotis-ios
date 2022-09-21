//
//  TalentSearchCard.swift
//  DinotisApp
//
//  Created by Gus Adi on 16/08/21.
//

import SwiftUI

struct TalentSearchCard: View {
	var onTapSee: (() -> Void)
	
	@Binding var user: Talent
	
	var body: some View {
		VStack(spacing: 0) {
			GeometryReader { geo in
				VStack(spacing: 0) {
					TalentPhotoProfile(profilePhoto: $user.profilePhoto, name: $user.name, width: geo.size.width, height: geo.size.height/1.3)
						.frame(height: geo.size.height/1.3)
					
					VStack(spacing: 5) {
						Text(user.name.orEmpty())
							.font(Font.custom(FontManager.Montserrat.bold, size: 12))
							.lineLimit(2)
							.foregroundColor(.black)
							.multilineTextAlignment(.center)
							.minimumScaleFactor(0.9)
						
						if let verified = user.isVerified {
							if verified {
								HStack {
									Image.Dinotis.accountVerifiedIcon
										.resizable()
										.scaledToFit()
										.frame(height: 12)
									
									Text(LocaleText.homeScreenVerified)
										.font(.montserratSemiBold(size: 11))
										.foregroundColor(.black)
								}
								.padding(.bottom, 4)
							}
						}
					}
					.padding(8)
				}
			}
		}
		.frame(width: 195, height: 225)
		.background(Color.white)
		.clipShape(RoundedRectangle(cornerRadius: 12))
		.shadow(color: Color("dinotis-shadow-1").opacity(0.08), radius: 10, x: 0.0, y: 0.0)
		.onTapGesture {
			onTapSee()
		}
	}
}
